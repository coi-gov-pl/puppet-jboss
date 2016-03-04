require 'spec_helper_puppet'

describe 'jboss::internal::configure::interfaces', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
  end

  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-conf-interfaces' }
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation
  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-conf-interfaces' }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation
  end
end
