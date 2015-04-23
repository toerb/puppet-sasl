require 'spec_helper'

shared_examples_for 'sasl' do
  it { should contain_anchor('sasl::begin') }
  it { should contain_anchor('sasl::end') }
  it { should contain_class('sasl') }
  it { should contain_class('sasl::config') }
  it { should contain_class('sasl::install') }
  it { should contain_class('sasl::params') }
end

describe 'sasl' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile }.to raise_error(/not supported on an Unsupported/) }
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

        it_behaves_like 'sasl'

        it { should contain_file('/etc/sasl2') }
        it { should contain_package('cyrus-sasl-lib') }
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

        it_behaves_like 'sasl'

        it { should contain_file('/usr/lib/sasl2') }
        it { should contain_package('libsasl2-2') }
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

        it_behaves_like 'sasl'

        it { should contain_file('/usr/lib/sasl2') }
        it { should contain_package('libsasl2-2') }
      end
    end
  end
end
