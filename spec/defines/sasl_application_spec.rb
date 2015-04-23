require 'spec_helper'

describe 'sasl::application' do

  let(:title) do
    'test'
  end

  context 'without sasl class included' do
    let(:params) do
      {
        :pwcheck_method => 'auxprop',
        :auxprop_plugin => 'sasldb',
        :mech_list      => ['plain', 'login'],
      }
    end

    it { expect { should compile }.to raise_error(/must include the sasl base class/) }
  end

  context 'with sasl class included' do
    let(:pre_condition) do
      'include ::sasl'
    end

    context 'with sasldb method' do
      let(:params) do
        {
          :pwcheck_method => 'auxprop',
          :auxprop_plugin => 'sasldb',
          :mech_list      => ['plain', 'login'],
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
            let(:facts) do
              super().merge(
                {
                  :operatingsystemmajrelease => version
                }
              )
            end

            it do
              should contain_file('/etc/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                pwcheck_method: auxprop
                mech_list: plain login
                auxprop_plugin: sasldb
              EOS
            end
            it { should contain_package('cyrus-sasl-plain') }
            it { should contain_sasl__application('test') }
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
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it do
              should contain_file('/usr/lib/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                pwcheck_method: auxprop
                mech_list: plain login
                auxprop_plugin: sasldb
              EOS
            end
            it { should contain_package('libsasl2-modules') }
            if codename == 'trusty'
              it { should contain_package('libsasl2-modules-db') }
            end
            it { should contain_sasl__application('test') }
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
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it do
              should contain_file('/usr/lib/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                pwcheck_method: auxprop
                mech_list: plain login
                auxprop_plugin: sasldb
              EOS
            end
            it { should contain_package('libsasl2-modules') }
            it { should contain_sasl__application('test') }
          end
        end
      end
    end

    context 'with saslauthd method' do
      let(:params) do
        {
          :pwcheck_method => 'saslauthd',
          :mech_list      => ['plain', 'login'],
        }
      end

      context 'without sasl::authd class included' do
        # Sufficient facts to get far enough to trigger the failure
        let(:facts) do
          {
            :osfamily                  => 'RedHat',
            :operatingsystemmajrelease => 7
          }
        end

        it { expect { should compile }.to raise_error(/must include the sasl::authd class/) }
      end

      context 'with sasl::authd class included' do
        let(:pre_condition) do
          'include ::sasl class { "::sasl::authd": mechanism => pam }'
        end

        context 'on RedHat' do
          let(:facts) do
            {
              :osfamily => 'RedHat'
            }
          end

          [6, 7].each do |version|
            context "version #{version}", :compile do
              let(:facts) do
                super().merge(
                  {
                    :operatingsystemmajrelease => version
                  }
                )
              end

              it do
                should contain_file('/etc/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                  pwcheck_method: saslauthd
                  mech_list: plain login
                EOS
              end
              it { should contain_package('cyrus-sasl-plain') }
              it { should contain_sasl__application('test') }
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
              let(:facts) do
                super().merge(
                  {
                    :lsbdistcodename => codename
                  }
                )
              end

              it do
                should contain_file('/usr/lib/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                  pwcheck_method: saslauthd
                  mech_list: plain login
                EOS
              end
              it { should contain_package('libsasl2-modules') }
              it { should contain_sasl__application('test') }
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
              let(:facts) do
                super().merge(
                  {
                    :lsbdistcodename => codename
                  }
                )
              end

              it do
                should contain_file('/usr/lib/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                  pwcheck_method: saslauthd
                  mech_list: plain login
                EOS
              end
              it { should contain_package('libsasl2-modules') }
              it { should contain_sasl__application('test') }
            end
          end
        end
      end
    end
  end
end
