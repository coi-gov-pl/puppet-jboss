require 'spec_helper_puppet'

describe 'jboss::internal::prerequisites', :type => :class do
  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss::internal::prerequisites' }
    it { is_expected.to contain_package('unzip') }
    it { is_expected.to contain_package('procps') }
    it { is_expected.to contain_package('coreutils') }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-prerequisites' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }
    it_behaves_like 'completly working define'
  end
  context 'On Debian os family' do
    let(:title) { 'test-module' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }
    it_behaves_like 'completly working define'
  end
end
