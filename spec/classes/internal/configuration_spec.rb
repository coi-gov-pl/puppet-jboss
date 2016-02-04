require 'spec_helper_puppet'

describe 'jboss::internal::configuration', :type => :class do
  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss::internal::configuration' }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_class 'jboss::params' }
    it { is_expected.to contain_class 'jboss::internal::params' }
    it { is_expected.to contain_class 'jboss::internal::runtime' }
    it { is_expected.to contain_class 'jboss::internal::augeas' }
    it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
    it { is_expected.to contain_class 'jboss::internal::quirks::etc_initd_functions' }
    it { is_expected.to contain_class 'jboss::internal::service' }

    it { is_expected.to contain_file('/etc/profile.d/jboss.sh').with({
      :ensure => 'file',
      :mode   => '0644'
      }) }

    it { is_expected.to contain_file('/var/log/wildfly/console.log').with({
      :ensure => 'file',
      :alias  => 'jboss::logfile',
      :owner  => 'root',
      :group  => 'jboss',
      :mode   => '0660'
      }) }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-configuration' }
    let(:facts) do
      {
        :operatingsystem => 'OracleLinux',
        :osfamily        => 'RedHat',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :puppetversion   => Puppet.version
      }
    end
    it_behaves_like 'completly working define'
  end

  context 'On Debian os family' do
    let(:title) { 'test-configuration' }
    let(:facts) do
      {
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :lsbdistcodename => 'trusty',
        :puppetversion   => Puppet.version
      }
    end
    it_behaves_like 'completly working define'
  end
end
