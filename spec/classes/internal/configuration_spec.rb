require 'spec_helper_puppet'

describe 'jboss::internal::configuration', :type => :class do
  let(:pre_condition) { <<-EOF
    class jboss::internal::service {
      $pwdlogfile = '/var/log/wildfly/console.log'
      $servicename = 'wildfly'
    }
    include jboss::internal::service

  EOF
  }

  shared_examples 'contains basic class structure' do
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::params') }
    it { is_expected.to contain_class('jboss::internal::params') }
    it { is_expected.to contain_class('jboss::internal::runtime') }
    it { is_expected.to contain_class('jboss::internal::augeas') }
    it { is_expected.to contain_class('jboss::internal::configure::interfaces') }
    it { is_expected.to contain_class('jboss::internal::quirks::etc_initd_functions') }
    it { is_expected.to contain_class('jboss::internal::configuration') }
  end

  shared_examples 'contains basic anchor structure' do
    it { is_expected.to contain_anchor('jboss::configuration::begin') }
    it { is_expected.to contain_anchor('jboss::configuration::end') }
  end

  shared_examples 'contains file structure' do
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
  end

  shared_examples 'contains self' do
    it { is_expected.to contain_concat('/etc/wildfly/wildfly.conf').with({
      :alias  => 'jboss::jboss-as.conf',
      :mode   => '0644'
      }) }
    it { is_expected.to contain_concat__fragment('jboss::jboss-as.conf::defaults').with({
      :order   => '000'
      }) }
  end

  context 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-configuration' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it_behaves_like 'contains self'
    it_behaves_like 'contains basic class structure'
    it_behaves_like 'contains basic anchor structure'
    it_behaves_like 'contains file structure'

    it { is_expected.to contain_file('/etc/sysconfig/wildfly.conf') }
  end

  context 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-configuration' }
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }

    it_behaves_like 'contains self'
    it_behaves_like 'contains basic class structure'
    it_behaves_like 'contains basic anchor structure'
    it_behaves_like 'contains file structure'

    it { is_expected.to contain_file('/etc/default/wildfly') }
  end
end
