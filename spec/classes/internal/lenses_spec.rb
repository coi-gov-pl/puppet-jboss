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
    let(:facts) do
      {
        :operatingsystem => 'OracleLinux',
        :osfamily        => 'RedHat',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :puppetversion   => Puppet.version
      }
    end
    it_behaves_like 'completly working define'
  end

  context 'On Debian os family' do
    let(:title) { 'test-lenses' }
    let(:facts) do
      {
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :lsbdistcodename => 'trusty',
        :puppetversion   => Puppet.version
      }
    end
    it_behaves_like 'completly working define'
  end
end
