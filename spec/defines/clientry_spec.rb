require 'spec_helper_puppet'

describe 'jboss::clientry', :type => :define do
  shared_examples 'contain self' do
    it do
      is_expected.to contain_jboss_confignode(title).with(
        :ensure => 'present',
        :path   => 'profile/test'
      )
    end
    it { is_expected.to contain_jboss_confignode(title).that_requires('Anchor[jboss::package::end]') }
    it do
      is_expected.to contain_jboss__clientry(title).with(
        :ensure => 'present',
        :path   => 'profile/test'
      )
    end
  end

  describe 'on RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples

    let(:title) { 'test-clientry' }
    let(:params) { { :path => 'profile/test' } }
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it_behaves_like containing_basic_class_structure

    it_behaves_like 'contain self'
  end

  describe 'on Debian os family' do
    extend Testing::RspecPuppet::SharedExamples

    let(:title) { 'test-clientry' }
    let(:params) { { :path => 'profile/test' } }
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }

    it_behaves_like containing_basic_class_structure

    it_behaves_like 'contain self'
  end
end
