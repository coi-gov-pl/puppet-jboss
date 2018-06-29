require 'spec_helper_puppet'

describe 'jboss::securitydomain', :type => :define do
  shared_examples 'contains class structure' do
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::internal::service') }
    it { is_expected.to contain_class('jboss::internal::runtime::node') }
    it do
      is_expected.to contain_jboss_securitydomain(title).with(
        :ensure     => 'present',
        :controller => '127.0.0.1'
      )
    end
  end

  shared_examples 'contains self' do
    it { is_expected.to contain_jboss__securitydomain('test-securitydomain') }
  end

  describe 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-securitydomain' }
    let(:params) do
      {
        :controller => '127.0.0.1'
      }
    end
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it_behaves_like 'contains class structure'
    it_behaves_like 'contains self'
  end

  describe 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-securitydomain' }
    let(:params) do
      {
        :controller => '127.0.0.1'
      }
    end
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }

    it_behaves_like 'contains class structure'
    it_behaves_like 'contains self'
  end
end
