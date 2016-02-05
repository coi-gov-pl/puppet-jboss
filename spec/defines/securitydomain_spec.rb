require 'spec_helper_puppet'

describe 'jboss::securitydomain', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class 'jboss::internal::runtime::node' }
    it { is_expected.to contain_jboss_securitydomain(title).with({
      :ensure => 'present'
      }) }
    it { is_expected.to contain_jboss__securitydomain(title) }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-securitydomain' }
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
end
