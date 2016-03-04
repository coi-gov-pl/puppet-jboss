require 'spec_helper_puppet'

describe 'jboss::internal::lenses', :type => :class do
  shared_examples 'completly working define' do
    it { is_expected.to contain_class 'jboss::internal::lenses' }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_file('/usr/lib/wildfly-8.2.0.Final/lenses/jbxml.aug').with({
      :ensure  => 'file',
      :source  => 'puppet:///modules/jboss/jbxml.aug',
      }) }
    it { is_expected.to contain_file('/usr/lib/wildfly-8.2.0.Final/lenses/jbxml.aug').that_requires(
      'File[/usr/lib/wildfly-8.2.0.Final/lenses/]'
      )}
    it { is_expected.to contain_file('/usr/lib/wildfly-8.2.0.Final/lenses').with({
      :ensure  => 'directory',
      :owner   => 'jboss',
      }) }
    it { is_expected.to contain_file('/usr/lib/wildfly-8.2.0.Final/lenses').that_requires(
      'Anchor[jboss::configuration::begin]'
      )}
  end

  context 'On RedHat os family' do
    let(:title) { 'test-lenses' }
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }
    it_behaves_like 'completly working define'
  end

  context 'On Debian os family' do
    let(:title) { 'test-lenses' }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }
    it_behaves_like 'completly working define'
  end
end
