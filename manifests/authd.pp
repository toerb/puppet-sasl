#
class sasl::authd (
  $mechanism,
  $package_name            = $::sasl::params::saslauthd_package,
  $service_name            = $::sasl::params::saslauthd_service,
  $socket                  = $::sasl::params::saslauthd_socket,
  $hasstatus               = $::sasl::params::saslauthd_hasstatus,
  # ldap
  $ldap_conf_file          = $::sasl::params::saslauthd_ldap_conf_file,
  $ldap_auth_method        = undef,
  $ldap_bind_dn            = undef,
  $ldap_bind_pw            = undef,
  $ldap_default_domain     = undef,
  $ldap_default_realm      = undef,
  $ldap_deref              = undef,
  $ldap_filter             = undef,
  $ldap_group_attr         = undef,
  $ldap_group_dn           = undef,
  $ldap_group_filter       = undef,
  $ldap_group_match_method = undef,
  $ldap_group_search_base  = undef,
  $ldap_group_scope        = undef,
  $ldap_password           = undef,
  $ldap_password_attr      = undef,
  $ldap_referrals          = undef,
  $ldap_restart            = undef,
  $ldap_id                 = undef,
  $ldap_authz_id           = undef,
  $ldap_mech               = undef,
  $ldap_realm              = undef,
  $ldap_scope              = undef,
  $ldap_search_base        = undef,
  $ldap_servers            = undef,
  $ldap_start_tls          = undef,
  $ldap_time_limit         = undef,
  $ldap_timeout            = undef,
  $ldap_tls_check_peer     = undef,
  $ldap_tls_cacert_file    = undef,
  $ldap_tls_cacert_dir     = undef,
  $ldap_tls_ciphers        = undef,
  $ldap_tls_cert           = undef,
  $ldap_tls_key            = undef,
  $ldap_use_sasl           = undef,
  $ldap_version            = undef,
  # rimap
  $imap_server             = undef,
) inherits ::sasl::params {

  if ! defined(Class['::sasl']) {
    fail('You must include the sasl base class before using the sasl::authd class') # lint:ignore:80chars
  }

  validate_re($mechanism, $::sasl::params::saslauthd_mechanisms)
  validate_string($package_name)
  validate_string($service_name)
  validate_absolute_path($socket)
  validate_bool($hasstatus)

  case $mechanism { # lint:ignore:case_without_default
    'ldap': {
      if $ldap_conf_file {
        validate_absolute_path($ldap_conf_file)
      }
      if $ldap_auth_method {
        validate_re($ldap_auth_method, '^(?:bind|custom|fastbind)$')
      }
      if $ldap_bind_dn {
        validate_string($ldap_bind_dn)
      }
      if $ldap_bind_pw {
        validate_string($ldap_bind_pw)
      }
      if $ldap_default_domain {
        validate_string($ldap_default_domain)
      }
      if $ldap_default_realm {
        validate_string($ldap_default_realm)
      }
      if $ldap_deref {
        validate_re($ldap_deref, '^(?:search|find|always|never)$')
      }
      if $ldap_filter {
        validate_string($ldap_filter)
      }
      if $ldap_group_attr {
        validate_string($ldap_group_attr)
      }
      if $ldap_group_dn {
        validate_string($ldap_group_dn)
      }
      if $ldap_group_filter {
        validate_string($ldap_group_filter)
      }
      if $ldap_group_match_method {
        validate_re($ldap_group_match_method, '^(?:attr|filter)$')
      }
      if $ldap_group_search_base {
        validate_string($ldap_group_search_base)
      }
      if $ldap_group_scope {
        validate_re($ldap_group_scope, '^(?:sub|one|base)$')
      }
      if $ldap_password {
        validate_string($ldap_password)
      }
      if $ldap_password_attr {
        validate_string($ldap_password_attr)
      }
      if $ldap_referrals {
        validate_bool($ldap_referrals)
      }
      if $ldap_restart {
        validate_bool($ldap_restart)
      }
      if $ldap_id {
        validate_string($ldap_id)
      }
      if $ldap_authz_id {
        validate_string($ldap_authz_id)
      }
      if $ldap_mech {
        validate_string($ldap_mech)
      }
      if $ldap_realm {
        validate_string($ldap_realm)
      }
      if $ldap_scope {
        validate_re($ldap_scope, '^(?:sub|one|base)$')
      }
      if $ldap_search_base {
        validate_string($ldap_search_base)
      }
      if $ldap_servers {
        validate_array($ldap_servers)
      }
      if $ldap_start_tls {
        validate_bool($ldap_start_tls)
      }
      if $ldap_time_limit {
        validate_integer($ldap_time_limit)
      }
      if $ldap_timeout {
        validate_integer($ldap_timeout)
      }
      if $ldap_tls_check_peer {
        validate_bool($ldap_tls_check_peer)
      }
      if $ldap_tls_cacert_file {
        validate_absolute_path($ldap_tls_cacert_file)
      }
      if $ldap_tls_cacert_dir {
        validate_absolute_path($ldap_tls_cacert_dir)
      }
      if $ldap_tls_ciphers {
        validate_string($ldap_tls_ciphers)
      }
      if $ldap_tls_cert {
        validate_absolute_path($ldap_tls_cert)
      }
      if $ldap_tls_key {
        validate_absolute_path($ldap_tls_key)
      }
      if $ldap_use_sasl {
        validate_bool($ldap_use_sasl)
      }
      if $ldap_version {
        validate_integer($ldap_version, 3, 2)
      }
    }
    'rimap': {
      validate_string($imap_server)
    }
  }

  include ::sasl::authd::install
  include ::sasl::authd::config
  include ::sasl::authd::service

  anchor { 'sasl::authd::begin': }
  anchor { 'sasl::authd::end': }

  Anchor['sasl::authd::begin'] -> Class['::sasl::authd::install']
    -> Class['::sasl::authd::config'] ~> Class['::sasl::authd::service']
    -> Anchor['sasl::authd::end']
}
