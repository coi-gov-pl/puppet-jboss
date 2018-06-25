require 'spec_helper_puppet'

describe 'jboss::internal::augeas', :type => :class do
  defs = {
    :version => '9.0.2.Final',
    :product => 'wildfly'
  }

  shared_examples 'contains self' do
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class 'jboss::internal::lenses' }
    it { is_expected.to contain_class 'jboss::internal::augeas' }
    it { is_expected.to contain_file("/usr/lib/#{defs[:product]}-#{defs[:version]}/lenses/jbxml.aug") }
  end

  context 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-augeas' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it_behaves_like 'contains self'
  end

  context 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-augeas' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }
    it_behaves_like 'contains self'
  end
end
