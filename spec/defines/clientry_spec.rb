require 'spec_helper_puppet'

describe 'jboss::clientry', :type => :define do

  shared_examples 'completly working define' do
    it do
      is_expected.to contain_jboss_confignode(title).with({
        :ensure => 'present',
        :path   => 'profile/test'
      })
    end
    it { is_expected.to contain_jboss_confignode(title).that_requires('Anchor[jboss::package::end]') }
    it do
      is_expected.to contain_jboss__clientry(title).with({
        :ensure => 'present',
        :path   => 'profile/test',
      })
    end
  end

  context 'on RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples

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
    it_behaves_like_full_working_jboss_installation
  end

  context 'on Debian os family' do
    extend Testing::RspecPuppet::SharedExamples

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
    it_behaves_like_full_working_jboss_installation
  end
end
