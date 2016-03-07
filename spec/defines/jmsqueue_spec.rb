require 'spec_helper_puppet'

describe 'jboss::jmsqueue', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to contain_jboss_jmsqueue(title).with({
      :ensure  => 'present',
      :entries => [
      'queue/app-mails',
      'java:jboss/exported/jms/queue/app-mails']
      }) }
    it { is_expected.to contain_jboss_jmsqueue(title).
      that_requires('Anchor[jboss::package::end]') }
    it { is_expected.to contain_jboss__jmsqueue(title).with({
      :ensure  => 'present',
      :entries => [
      'queue/app-mails',
      'java:jboss/exported/jms/queue/app-mails']
      }) }
  end

  context 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-jmsqueue' }
    let(:params) { { :entries => [
    'queue/app-mails',
    'java:jboss/exported/jms/queue/app-mails'], } }
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

  context 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-jmsqueue' }
    let(:params) { { :entries => [
    'queue/app-mails',
    'java:jboss/exported/jms/queue/app-mails'], } }
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
