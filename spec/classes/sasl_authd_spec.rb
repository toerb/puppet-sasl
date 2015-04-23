require 'spec_helper'

shared_examples_for 'sasl::authd' do
  it { should contain_anchor('sasl::authd::begin') }
  it { should contain_anchor('sasl::authd::end') }
  it { should contain_class('sasl::authd') }
  it { should contain_class('sasl::authd::config') }
  it { should contain_class('sasl::authd::install') }
  it { should contain_class('sasl::authd::service') }
  it { should contain_service('saslauthd') }
end

describe 'sasl::authd' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile }.to raise_error(/not supported on an Unsupported/) }
  end

  context 'with pam mechanism' do
    let(:params) do
      {
        :mechanism => 'pam'
      }
    end

    context 'on RedHat' do
      let(:facts) do
        {
          :osfamily => 'RedHat'
        }
      end

      [6, 7].each do |version|
        context "version #{version}", :compile do

          let(:pre_condition) do
            'include ::sasl'
          end

          let(:facts) do
            super().merge(
              {
                :operatingsystemmajrelease => version
              }
            )
          end

          it_behaves_like 'sasl::authd'

          it { should contain_file('/etc/saslauthd.conf').with_ensure('absent') }

          case version
          when 6
            it do
              should contain_file('/etc/sysconfig/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

                SOCKETDIR="/var/run/saslauthd"
                MECH="pam"
                FLAGS=""
              EOS
            end
          else
            it do
              should contain_file('/etc/sysconfig/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

                SOCKETDIR="/run/saslauthd"
                MECH="pam"
                FLAGS=""
              EOS
            end
          end

          it { should contain_package('cyrus-sasl') }
        end
      end
    end

    context 'on Ubuntu' do
      let(:facts) do
        {
          :osfamily        => 'Debian',
          :operatingsystem => 'Ubuntu',
          :lsbdistid       => 'Ubuntu'
        }
      end

      ['precise', 'trusty'].each do |codename|
        context "#{codename}", :compile do

          let(:pre_condition) do
            'include ::sasl'
          end

          let(:facts) do
            super().merge(
              {
                :lsbdistcodename => codename
              }
            )
          end

          it_behaves_like 'sasl::authd'

          it do
            should contain_file('/etc/default/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
              # !!! Managed by Puppet !!!

              START=yes
              DESC="SASL Authentication Daemon"
              NAME="saslauthd"
              MECHANISMS="pam"
              MECH_OPTIONS=""
              THREADS=5
              OPTIONS="-c -m /var/run/saslauthd"
            EOS
          end
          it { should contain_file('/etc/saslauthd.conf').with_ensure('absent') }
          it { should contain_package('sasl2-bin') }
        end
      end
    end

    context 'on Debian' do
      let(:facts) do
        {
          :osfamily        => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistid       => 'Debian'
        }
      end

      ['squeeze', 'wheezy'].each do |codename|
        context "#{codename}", :compile do

          let(:pre_condition) do
            'include ::sasl'
          end

          let(:facts) do
            super().merge(
              {
                :lsbdistcodename => codename
              }
            )
          end

          it_behaves_like 'sasl::authd'

          it do
            should contain_file('/etc/default/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
              # !!! Managed by Puppet !!!

              START=yes
              DESC="SASL Authentication Daemon"
              NAME="saslauthd"
              MECHANISMS="pam"
              MECH_OPTIONS=""
              THREADS=5
              OPTIONS="-c -m /var/run/saslauthd"
            EOS
          end
          it { should contain_file('/etc/saslauthd.conf').with_ensure('absent') }
          it { should contain_package('sasl2-bin') }
        end
      end
    end
  end

  context 'with ldap mechanism' do
    let(:params) do
      {
        :mechanism => 'ldap'
      }
    end

    context 'on RedHat' do
      let(:facts) do
        {
          :osfamily => 'RedHat'
        }
      end

      [6, 7].each do |version|
        context "version #{version}", :compile do

          let(:pre_condition) do
            'include ::sasl'
          end

          let(:facts) do
            super().merge(
              {
                :operatingsystemmajrelease => version
              }
            )
          end

          context 'with default parameters' do

            it_behaves_like 'sasl::authd'

            it do
              should contain_file('/etc/saslauthd.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

              EOS
            end

            case version
            when 6
              it do
                should contain_file('/etc/sysconfig/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                  # !!! Managed by Puppet !!!

                  SOCKETDIR="/var/run/saslauthd"
                  MECH="ldap"
                  FLAGS=""
                EOS
              end
            else
              it do
                should contain_file('/etc/sysconfig/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                  # !!! Managed by Puppet !!!

                  SOCKETDIR="/run/saslauthd"
                  MECH="ldap"
                  FLAGS=""
                EOS
              end
            end

            it { should contain_package('cyrus-sasl') }
          end

          context 'with alternate configuration file and specified parameters' do
            let(:params) do
              super().merge(
                {
                  :ldap_conf_file => '/tmp/saslauthd.conf'
                  # TODO
                }
              )
            end

            it_behaves_like 'sasl::authd'

            it { should_not contain_file('/etc/saslauthd.conf') }
            it do
              should contain_file('/tmp/saslauthd.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

              EOS
            end

            case version
            when 6
              it do
                should contain_file('/etc/sysconfig/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                  # !!! Managed by Puppet !!!

                  SOCKETDIR="/var/run/saslauthd"
                  MECH="ldap"
                  FLAGS="-O /tmp/saslauthd.conf"
                EOS
              end
            else
              it do
                should contain_file('/etc/sysconfig/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                  # !!! Managed by Puppet !!!

                  SOCKETDIR="/run/saslauthd"
                  MECH="ldap"
                  FLAGS="-O /tmp/saslauthd.conf"
                EOS
              end
            end

            it { should contain_package('cyrus-sasl') }
          end
        end
      end
    end

    context 'on Ubuntu' do
      let(:facts) do
        {
          :osfamily        => 'Debian',
          :operatingsystem => 'Ubuntu',
          :lsbdistid       => 'Ubuntu'
        }
      end

      ['precise', 'trusty'].each do |codename|
        context "#{codename}", :compile do

          let(:pre_condition) do
            'include ::sasl'
          end

          let(:facts) do
            super().merge(
              {
                :lsbdistcodename => codename
              }
            )
          end

          context 'with default parameters' do

            it_behaves_like 'sasl::authd'

            it do
              should contain_file('/etc/default/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

                START=yes
                DESC="SASL Authentication Daemon"
                NAME="saslauthd"
                MECHANISMS="ldap"
                MECH_OPTIONS=""
                THREADS=5
                OPTIONS="-c -m /var/run/saslauthd"
              EOS
            end
            it do
              should contain_file('/etc/saslauthd.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

              EOS
            end
            it { should contain_package('sasl2-bin') }
          end

          context 'with alternate configuration file and specified parameters' do
            let(:params) do
              super().merge(
                {
                  :ldap_conf_file => '/tmp/saslauthd.conf'
                  # TODO
                }
              )
            end

            it_behaves_like 'sasl::authd'

            it do
              should contain_file('/etc/default/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

                START=yes
                DESC="SASL Authentication Daemon"
                NAME="saslauthd"
                MECHANISMS="ldap"
                MECH_OPTIONS="-O /tmp/saslauthd.conf"
                THREADS=5
                OPTIONS="-c -m /var/run/saslauthd"
              EOS
            end
            it { should_not contain_file('/etc/saslauthd.conf') }
            it do
              should contain_file('/tmp/saslauthd.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

              EOS
            end
            it { should contain_package('sasl2-bin') }
          end
        end
      end
    end

    context 'on Debian' do
      let(:facts) do
        {
          :osfamily        => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistid       => 'Debian'
        }
      end

      ['squeeze', 'wheezy'].each do |codename|
        context "#{codename}", :compile do

          let(:pre_condition) do
            'include ::sasl'
          end

          let(:facts) do
            super().merge(
              {
                :lsbdistcodename => codename
              }
            )
          end

          context 'with default parameters' do

            it_behaves_like 'sasl::authd'

            it do
              should contain_file('/etc/default/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

                START=yes
                DESC="SASL Authentication Daemon"
                NAME="saslauthd"
                MECHANISMS="ldap"
                MECH_OPTIONS=""
                THREADS=5
                OPTIONS="-c -m /var/run/saslauthd"
              EOS
            end
            it do
              should contain_file('/etc/saslauthd.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

              EOS
            end
            it { should contain_package('sasl2-bin') }
          end

          context 'with alternate configuration file and specified parameters' do
            let(:params) do
              super().merge(
                {
                  :ldap_conf_file => '/tmp/saslauthd.conf'
                  # TODO
                }
              )
            end

            it_behaves_like 'sasl::authd'

            it do
              should contain_file('/etc/default/saslauthd').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

                START=yes
                DESC="SASL Authentication Daemon"
                NAME="saslauthd"
                MECHANISMS="ldap"
                MECH_OPTIONS="-O /tmp/saslauthd.conf"
                THREADS=5
                OPTIONS="-c -m /var/run/saslauthd"
              EOS
            end
            it { should_not contain_file('/etc/saslauthd.conf') }
            it do
              should contain_file('/tmp/saslauthd.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                # !!! Managed by Puppet !!!

              EOS
            end
            it { should contain_package('sasl2-bin') }
          end
        end
      end
    end
  end
end
