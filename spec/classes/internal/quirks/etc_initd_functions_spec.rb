require 'spec_helper_puppet'

describe 'jboss::internal::quirks::etc_initd_functions', :type => :define do
  shared_examples 'contains class structure' do
    it { is_expected.to contain_class 'jboss::internal::quirks::etc_initd_functions' }
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::internal::service') }
    it { is_expected.to contain_class('jboss::internal::compatibility') }
  end

  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-etc_initd_functions' }
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }
    it_behaves_like 'contains class structure'

  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-etc_initd_functions' }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }
    it_behaves_like 'contains class structure'

  end
end
