require 'spec_helper_puppet'

describe 'jboss::internal::configure::interfaces', :type => :class do
  shared_examples 'contains jboss::internal::configure::interfaces classes' do
    it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::params') }
    it { is_expected.to contain_class('jboss::internal::runtime::dc') }
  end

  describe 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-conf-interfaces' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it_behaves_like 'contains jboss::internal::configure::interfaces classes'
  end

  describe 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-conf-interfaces' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }

    it_behaves_like 'contains jboss::internal::configure::interfaces classes'
  end
end
