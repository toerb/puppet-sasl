#
define sasl::application (
  $pwcheck_method,
  $mech_list,
  $auxprop_plugin  = undef,
  # ldapdb
  $ldapdb_uri      = undef,
  $ldapdb_id       = undef,
  $ldapdb_mech     = undef,
  $ldapdb_pw       = undef,
  $ldapdb_rc       = undef,
  $ldapdb_starttls = undef,
  # sasldb
  $sasldb_path     = undef,
  # sql
  $sql_engine      = undef,
  $sql_hostnames   = undef,
  $sql_user        = undef,
  $sql_passwd      = undef,
  $sql_database    = undef,
  $sql_select      = undef,
  $sql_insert      = undef,
  $sql_update      = undef,
  $sql_usessl      = undef,
) {

  if ! defined(Class['::sasl']) {
    fail('You must include the sasl base class before using any sasl defined resources') # lint:ignore:80chars
  }

  validate_re($pwcheck_method, '^(?:auxprop|saslauthd)$')
  validate_array($mech_list)

  if $pwcheck_method == 'auxprop' {
    validate_re($auxprop_plugin, '^(?:ldapdb|sasldb|sql)$')

    # Validate per-auxprop parameters
    case $auxprop_plugin { # lint:ignore:case_without_default
      'ldapdb': {
        if $ldapdb_uri {
          validate_array($ldapdb_uri)
        }
        if $ldapdb_id {
          validate_string($ldapdb_id)
        }
        if $ldapdb_mech {
          validate_string($ldapdb_mech)
        }
        if $ldapdb_pw {
          validate_string($ldapdb_pw)
        }
        if $ldapdb_rc {
          validate_absolute_path($ldapdb_rc)
        }
        if $ldapdb_starttls {
          validate_re($ldapdb_starttls, '^(?:try|demand)$')
        }
      }
      'sasldb': {
        if $sasldb_path {
          validate_absolute_path($sasldb_path)
        }
      }
      'sql': {
        if $sql_engine {
          validate_re($sql_engine, '^(?:mysql|pgsql|sqlite)$')
        }
        if $sql_hostnames {
          validate_array($sql_hostnames)
        }
        if $sql_user {
          validate_string($sql_user)
        }
        if $sql_passwd {
          validate_string($sql_passwd)
        }
        if $sql_database {
          validate_string($sql_database)
        }
        validate_string($sql_select)
        if $sql_insert {
          validate_string($sql_insert)
        }
        if $sql_update {
          validate_string($sql_update)
        }
        if $sql_usessl {
          validate_bool($sql_usessl)
        }
      }
    }
  }

  $service_file = "${::sasl::application_directory}/${name}.conf"

  file { $service_file:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template('sasl/application.conf.erb'),
  }

  if $pwcheck_method == 'auxprop' {
    $auxprop_package = $::sasl::auxprop_packages[$auxprop_plugin]
    ensure_packages([$auxprop_package])
    Package[$auxprop_package] -> File[$service_file]
  }

  # Build up an array of packages that need to be installed based on the
  # chosen authentication mechanisms
  $mech_packages = $::sasl::mech_packages
  $packages = split(inline_template('<%= Hash[@mech_packages.select { |k,v| @mech_list.include?(k) }].values.uniq.join(",") %>'), ',') # lint:ignore:80chars
  ensure_packages($packages)
  Package[$packages] -> File[$service_file]

  # Require saslauthd if that's the method
  if $pwcheck_method == 'saslauthd' {
    if ! defined(Class['::sasl::authd']) {
      fail('You must include the sasl::authd class before using any sasl defined resources') # lint:ignore:80chars
    }
    Service[$sasl::authd::service_name] -> File[$service_file]
  }
}
