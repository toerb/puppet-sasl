require 'spec_helper'

describe 'sasl::application' do

  let(:title) do
    'test'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
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

        context 'with sasldb method', :compile do
          let(:params) do
            {
              :pwcheck_method => 'auxprop',
              :auxprop_plugin => 'sasldb',
              :mech_list      => ['plain', 'login'],
            }
          end

          case facts[:osfamily]
          when 'Debian'
            it do
              should contain_file('/usr/lib/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                pwcheck_method: auxprop
                mech_list: plain login
                auxprop_plugin: sasldb
              EOS
            end
            it { should contain_package('libsasl2-modules') }

            case facts[:operatingsystem]
            when 'Ubuntu'
              case facts[:lsbdistcodename]
              when 'trusty'
                it { should contain_package('libsasl2-modules-db') }
              end
            end
          when 'RedHat'
            it do
              should contain_file('/etc/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                pwcheck_method: auxprop
                mech_list: plain login
                auxprop_plugin: sasldb
              EOS
            end
            it { should contain_package('cyrus-sasl-plain') }
          end

          it { should contain_sasl__application('test') }
        end

        context 'with saslauthd method' do
          let(:params) do
            {
              :pwcheck_method => 'saslauthd',
              :mech_list      => ['plain', 'login'],
            }
          end

          context 'without sasl::authd class included' do
            it { expect { should compile }.to raise_error(/must include the sasl::authd class/) }
          end

          context 'with sasl::authd class included', :compile do
            let(:pre_condition) do
              'include ::sasl class { "::sasl::authd": mechanism => pam }'
            end

            case facts[:osfamily]
            when 'Debian'
              it do
                should contain_file('/usr/lib/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                  pwcheck_method: saslauthd
                  mech_list: plain login
                EOS
              end
              it { should contain_package('libsasl2-modules') }
            when 'RedHat'
              it do
                should contain_file('/etc/sasl2/test.conf').with_content(<<-EOS.gsub(/^ +/, ''))
                  pwcheck_method: saslauthd
                  mech_list: plain login
                EOS
              end
              it { should contain_package('cyrus-sasl-plain') }
            end

            it { should contain_sasl__application('test') }
          end
        end
      end
    end
  end
end
