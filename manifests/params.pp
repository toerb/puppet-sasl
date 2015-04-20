#
class sasl::params {

  case $::osfamily {
    'RedHat': {
      $package_name          = 'cyrus-sasl-lib'
      $application_directory = '/etc/sasl2'
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.") # lint:ignore:80chars
    }
  }
}
