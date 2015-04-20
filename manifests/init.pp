#
class sasl (
  $application_directory = $::sasl::params::application_directory,
  $package_name          = $::sasl::params::package_name,
) inherits ::sasl::params {

  include ::sasl::install
  include ::sasl::config

  anchor { 'sasl::begin': }
  anchor { 'sasl::end': }

  Anchor['sasl::begin'] -> Class['::sasl::install'] -> Class['::sasl::config']
    -> Anchor['sasl::end']
}
