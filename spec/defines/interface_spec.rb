require 'spec_helper_puppet'

describe 'jboss::interface', :type => :define do
  bind_variables_list = [
    "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual",
    "any-ipv4-address", "any-ipv6-address" ]

  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss::params' }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_class 'jboss::internal::augeas' }
    it { is_expected.to contain_class 'jboss::internal::runtime' }
    it { is_expected.to contain_jboss__interface(title) }
    it { is_expected.to contain_jboss__interface('public') }
    bind_variables_list.each do |var|
      it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
      it { is_expected.to contain_augeas("interface public rm #{var}") }
      it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}")}
      it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}")}
    end
    it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:any-address")}
    it { is_expected.to contain_jboss__internal__interface__foreach("public:any-address")}
    it { is_expected.to contain_augeas("ensure present interface #{title}") }
    it { is_expected.to contain_augeas("ensure present interface public") }
    it { is_expected.to contain_augeas("interface #{title} set any-address") }
    it { is_expected.to contain_augeas("interface public set any-address") }

  end
  context 'On RedHat os family' do
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
  end

  context 'On Debian os family' do
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
  end
end
