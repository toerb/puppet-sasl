require 'spec_helper_acceptance'

describe 'sasl' do

  it 'should work with no errors' do
    pp = <<-EOS
      include ::sasl
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe file('/etc/sasl2') do
    it { should be_directory }
  end

  describe package('cyrus-sasl-lib') do
    it { should be_installed }
  end
end
