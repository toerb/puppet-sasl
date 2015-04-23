require 'spec_helper_acceptance'

describe 'sasl::authd' do
  case fact('osfamily')
  when 'RedHat'
    package_name = 'cyrus-sasl'
    pam_service  = 'system-auth'
  when 'Debian'
    package_name = 'sasl2-bin'
    pam_service  = 'common-auth'
  end

  context 'with pam mechanism' do

    it 'should work with no errors' do
      pp = <<-EOS
        group { 'test':
          ensure => present,
          gid    => 2000,
        }
        user { 'test':
          ensure     => present,
          comment    => 'Test user',
          gid        => 2000,
          managehome => true,
          # test
          password   => '$6$VWLrFvt.$NvABeDqNvdlTagbYRZADaSEzA9w1/Ny7XtDneE2EZZ8GVMdY9FLMUQMfTVUJEE8cbNt8.3RGBjjoGBj1sFzbX0',
          shell      => '/bin/bash',
          uid        => 2000,
          require    => Group['test'],
        }
        include ::sasl
        class { '::sasl::authd':
          mechanism => pam,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package(package_name) do
      it { should be_installed }
    end

    # Debian Squeeze doesn't support 'service saslauthd status'
    describe service('saslauthd'), :if => fact('lsbdistcodename') != 'squeeze' do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('saslauthd'), :if => fact('lsbdistcodename') == 'squeeze' do
      it { should be_enabled }
    end

    describe process('saslauthd'), :if => fact('lsbdistcodename') == 'squeeze' do
      it { should be_running }
    end

    describe command("testsaslauthd -u test -p test -s #{pam_service}") do
      its(:stdout) { should match /^0: OK "Success."/ }
      its(:exit_status) { should eq 0 }
    end

    #describe command("testsaslauthd -u test -p invalid -s #{pam_service}") do
    #  its(:stdout) { should match /^0: NO "authentication failed"/ }
    #  its(:exit_status) { should eq 255 }
    #end
  end

  context 'with ldap mechanism' do
    # TODO
  end
end
