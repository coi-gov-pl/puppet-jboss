require 'spec_helper_puppet'

describe 'jboss::internal::lenses', :type => :class do
  DEFAULT_VERSION = '9.0.2.Final'
  DEFAULT_PRODUCT = 'wildfly'
  let(:pre_condition)  { "class { jboss: install_dir => '/usr/lib', product => 'wildfly', version => '9.0.2.Final', jboss_user => 'jboss'}" }

  shared_examples 'completly working define' do
    it { is_expected.to contain_class 'jboss::internal::lenses' }
    it { is_expected.to contain_class 'jboss' }

    it { is_expected.to contain_file("/usr/lib/#{DEFAULT_PRODUCT}-#{DEFAULT_VERSION}/lenses").with({
      :ensure  => 'directory',
      :owner   => 'jboss',
      }) }
    it { is_expected.to contain_file("/usr/lib/#{DEFAULT_PRODUCT}-#{DEFAULT_VERSION}/lenses").that_requires(
      'Anchor[jboss::configuration::begin]'
      )}
  end

  context 'On RedHat os family' do
    let(:title) { 'test-lenses' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }
    it_behaves_like 'completly working define'
  end

  context 'On Debian os family' do
    let(:title) { 'test-lenses' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }
    it_behaves_like 'completly working define'
  end
end
