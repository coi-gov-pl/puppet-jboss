require 'spec_helper_puppet'

describe 'jboss', :type => :class do
  let(:facts) do
    {
      :operatingsystem => 'OracleLinux',
      :osfamily        => 'RedHat',
      :ipaddress       => '192.168.0.1',
      :concat_basedir  => '/root/concat',
      :puppetversion   => Puppet.version
    }
  end
  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it do
      is_expected.to contain_class('jboss').with({
        :product      => 'wildfly',
        :version      => '9.0.2.Final',
        :download_url => 'http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.zip'
        })
    end
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
    it { is_expected.to contain_user 'jboss' }
    it { is_expected.to contain_group 'jboss' }
    it { is_expected.to contain_class('jboss::internal::package').with ({
      :version      => '8.2.0.Final',
      :product      => 'wildfly',
      :jboss_user   => 'jboss',
      :jboss_group  => 'jboss',
      :java_version => 'latest'
      })}
  end
  context 'with product => jboss-eap and version => 6.4.0.GA parameters set' do
    let(:params) do
      { :product => 'jboss-eap', :version => '6.4.0.GA' }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_user 'jboss' }
    it { is_expected.to contain_group 'jboss' }
  end
  context 'with jboss_user => appserver parameter set' do
    let(:params) do
      { :jboss_user => 'appserver' }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_user 'appserver' }
    it { is_expected.to contain_group 'jboss' }
  end
  context 'with download_url => file:///tmp/wildfly-8.2.0.Final.zip set' do
    let(:params) do
      { :download_url => 'file:///tmp/wildfly-8.2.0.Final.zip' }
    end

    it do
      is_expected.to contain_class('jboss').with({
        :download_url => 'file:///tmp/wildfly-8.2.0.Final.zip'
        })
    end
    it { is_expected.to contain_class 'jboss::params' }
    it { is_expected.to contain_class 'jboss::internal::compatibility' }
    it { is_expected.to contain_class 'jboss::internal::configuration' }
    it { is_expected.to contain_class 'jboss::internal::service' }
  end
end
