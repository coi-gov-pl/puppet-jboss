require 'spec_helper_puppet'

describe 'jboss::internal::prerequisites', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss::internal::prerequisites' }
    it { is_expected.to contain_package('unzip') }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-prerequisites' }
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }
    it_behaves_like 'completly working define'
  end
  context 'On Debian os family' do
    let(:title) { 'test-module' }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }
    it_behaves_like 'completly working define'
  end
end
