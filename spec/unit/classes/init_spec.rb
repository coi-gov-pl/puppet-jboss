require 'spec_helper'
describe 'jboss', :type => :class do
  let(:facts) do
    { 
      :operatingsystem => 'OracleLinux',
      :osfamily        => 'RedHat', 
      :ipaddress       => '192.168.0.1',
      :concat_basedir  => '/root/concat',
      :puppetversion   => Puppet.version,
    }
  end
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
  end
end
