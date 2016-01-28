require 'spec_helper_puppet'

describe 'jboss::clientry', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_jboss_confignode(title).with ({
      :ensure => 'present',
      :path   => 'profile/test'
      }) }
    it { is_expected.to contain_jboss_confignode(title).that_requires('Anchor[jboss::package::end]')}
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_jboss__clientry(title) }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class 'jboss::internal::runtime::node' }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-clientry' }
    let(:params) { { :path => 'profile/test', } }
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
    let(:title) { 'test-clientry' }
    let(:params) { { :path => 'profile/test', } }
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
