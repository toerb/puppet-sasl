#
class sasl (
  $application_directory = $::sasl::params::application_directory,
  $package_name          = $::sasl::params::package_name,
  $auxprop_packages      = $::sasl::params::auxprop_packages,
  $mech_packages         = $::sasl::params::mech_packages,
) inherits ::sasl::params {

  validate_absolute_path($application_directory)
  validate_string($package_name)
  validate_hash($auxprop_packages)
  validate_hash($mech_packages)

  include ::sasl::install
  include ::sasl::config

  anchor { 'sasl::begin': }
  anchor { 'sasl::end': }

  Anchor['sasl::begin'] -> Class['::sasl::install'] -> Class['::sasl::config']
    -> Anchor['sasl::end']
}
