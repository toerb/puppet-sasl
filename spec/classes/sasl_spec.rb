require 'spec_helper'

describe 'sasl' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it do
      expect { should compile }.to raise_error(/not supported on an Unsupported/)
    end
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
          should contain_anchor('sasl::begin')
          should contain_anchor('sasl::end')
          should contain_class('sasl')
          should contain_class('sasl::config')
          should contain_class('sasl::install')
          should contain_class('sasl::params')
          should contain_file('/etc/sasl2')
          should contain_package('cyrus-sasl-lib')
        end
      end
    end
  end
end
