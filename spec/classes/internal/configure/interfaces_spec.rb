require 'spec_helper_puppet'

describe 'jboss::internal::configure::interfaces', :type => :define do
  shared_examples 'contains self' do
    it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::params') }
    it { is_expected.to contain_class('jboss::internal::runtime::dc') }
  end

  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-conf-interfaces' }
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }

    it_behaves_like 'contains self'
  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-conf-interfaces' }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }

    it_behaves_like 'contains self'
  end
end
