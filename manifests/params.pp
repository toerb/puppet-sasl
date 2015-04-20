#
class sasl::params {

  case $::osfamily {
    'RedHat': {
      $package_name          = 'cyrus-sasl-lib'
      $application_directory = '/etc/sasl2'
      $auxprop_packages      = {
        'ldapdb' => 'cyrus-sasl-ldap',
        'sasldb' => 'cyrus-sasl-lib',
        'sql'    => 'cyrus-sasl-sql',
      }
      $sasldb_package        = 'cyrus-sasl-lib'
      $mech_packages         = {
        'anonymous'  => 'cyrus-sasl-lib',
        'cram-md5'   => 'cyrus-sasl-md5',
        'digest-md5' => 'cyrus-sasl-md5',
        'login'      => 'cyrus-sasl-plain',
        'ntlm'       => 'cyris-sasl-ntlm',
        'plain'      => 'cyrus-sasl-plain',
      }
      $saslauthd_package     = 'cyrus-sasl'
    }
    'Debian': {
      $package_name          = 'libsasl2-2'
      $application_directory = '/usr/lib/sasl2'
      $auxprop_packages      = {
        'ldapdb' => 'libsasl2-modules-ldap',
        'sasldb' => $::lsbdistcodename ? {
          'trusty' => 'libsasl2-modules-db',
          default  => 'libsasl2-modules',
        },
        'sql'    => 'libsasl2-modules-sql',
      }
      $sasldb_package        = 'sasl2-bin'
      $mech_packages         = {
        'anonymous'  => 'libsasl2-modules',
        'cram-md5'   => 'libsasl2-modules',
        'digest-md5' => 'libsasl2-modules',
        'login'      => 'libsasl2-modules',
        'ntlm'       => 'libsasl2-modules',
        'plain'      => 'libsasl2-modules',
      }
      $saslauthd_package     = 'sasl2-bin'
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.") # lint:ignore:80chars
    }
  }
}
