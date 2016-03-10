require 'spec_helper_puppet'

describe 'jboss::jmsqueue', :type => :define do
  shared_examples 'contains self' do
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
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }

    it_behaves_like containing_basic_class_structure
    it_behaves_like 'contains self'
  end

  context 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-jmsqueue' }
    let(:params) { { :entries => [
    'queue/app-mails',
    'java:jboss/exported/jms/queue/app-mails'], } }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }

    it_behaves_like containing_basic_class_structure
    it_behaves_like 'contains self'
  end
end
