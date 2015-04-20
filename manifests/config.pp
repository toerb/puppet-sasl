#
class sasl::config {

  file { $::sasl::application_directory:
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    purge   => true,
    recurse => true,
  }
}
