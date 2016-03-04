require 'spec_helper_puppet'

describe 'jboss::internal::configuration', :type => :class do
  shared_examples 'completly working define' do
    it { is_expected.to contain_class 'jboss::internal::configuration' }
    it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
    it { is_expected.to contain_class 'jboss::internal::quirks::etc_initd_functions' }
    it { is_expected.to contain_file('/etc/profile.d/jboss.sh').with({
      :ensure => 'file',
      :mode   => '0644'
      }) }

    it { is_expected.to contain_file('/var/log/wildfly/console.log').with({
      :ensure => 'file',
      :alias  => 'jboss::logfile',
      :owner  => 'root',
      :group  => 'jboss',
      :mode   => '0660'
      }) }

    it { is_expected.to contain_file('/etc/jboss-as').with({
      :ensure => 'directory',
      :mode   => '2770',
      :owner  => 'jboss',
      :group  => 'jboss'
      }) }

    it { is_expected.to contain_file('/etc/jboss-as/jboss-as.conf').
      with_ensure('link').
      that_comes_before('Anchor[jboss::configuration::end]') }

    it { is_expected.to contain_file('/etc/default').with_ensure('directory') }

    it { is_expected.to contain_file('/etc/default/wildfly.conf').
      with_ensure('link').
      that_comes_before('Anchor[jboss::configuration::end]') }

    it { is_expected.to contain_concat('/etc/wildfly/wildfly.conf').with({
      :alias  => 'jboss::jboss-as.conf',
      :mode   => '0644'
      }) }
    it { is_expected.to contain_concat__fragment('jboss::jboss-as.conf::defaults').with({
      :order   => '000'
      }) }
  end

  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-configuration' }
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation
    it { is_expected.to contain_file('/etc/sysconfig/wildfly.conf') }
  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-configuration' }
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation
    it { is_expected.to contain_file('/etc/default/wildfly') }
  end
end
