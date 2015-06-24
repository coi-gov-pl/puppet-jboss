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
    it { is_expected.to contain_anchor 'jboss::begin' }
    it { is_expected.to contain_anchor 'jboss::end' }
    it { is_expected.to contain_anchor 'jboss::configuration::begin' }
    it { is_expected.to contain_anchor 'jboss::configuration::end' }
    it { is_expected.to contain_anchor 'jboss::installed' }
    it { is_expected.to contain_anchor 'jboss::package::begin' }
    it { is_expected.to contain_anchor 'jboss::package::end' }
    it { is_expected.to contain_anchor 'jboss::service::begin' }
    it { is_expected.to contain_anchor 'jboss::service::end' }
    it { is_expected.to contain_anchor 'jboss::service::started' }
    
  end
end
