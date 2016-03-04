require 'spec_helper_puppet'

describe 'jboss::internal::augeas', :type => :class do
  DEFAULT_VERSION = '9.0.2.Final'
  DEFAULT_PRODUCT = 'wildfly'

  shared_examples 'completly working define' do
    it { is_expected.to contain_class 'jboss::internal::lenses' }
    it { is_expected.to contain_class 'jboss::internal::augeas' }
    it { is_expected.to contain_file("/usr/lib/#{DEFAULT_PRODUCT}-#{DEFAULT_VERSION}/lenses/jbxml.aug") }
  end

  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-augeas' }
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation

  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-augeas' }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation

  end
end
