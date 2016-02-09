require 'spec_helper_puppet'

describe 'jboss::interface', :type => :define do
  bind_variables_list = [
    "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual",
    "any-ipv4-address", "any-ipv6-address" ]

  shared_examples 'completly working define' do
    it { is_expected.to contain_jboss__interface(title) }
    it { is_expected.to contain_jboss__internal__interface__foreach('test-interface:any-address') }
    it { is_expected.to contain_augeas('ensure present interface test-interface') }
    it { is_expected.to contain_augeas('interface test-interface set any-address') }
    bind_variables_list.each do |var|
      it { is_expected.to contain_augeas("interface test-interface rm #{var}") }
      it { is_expected.to contain_jboss__internal__interface__foreach("test-interface:#{var}") }
      end
  end
  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-interface' }
    let(:facts) do
      {
        :operatingsystem => 'OracleLinux',
        :osfamily        => 'RedHat',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :puppetversion   => Puppet.version
      }
    end
    let(:params) do
      {
        :any_address => 'true',
      }
    end
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation
  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-interface' }
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
    let(:params) do
      {
        :any_address => 'true',
      }
    end
    it_behaves_like 'completly working define'
    it_behaves_like_full_working_jboss_installation
  end
end
