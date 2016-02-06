require 'spec_helper_puppet'

describe 'jboss::internal::service', :type => :define do
  basic_bind_variables_list = [
    "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual" ]

  anchor_list = [
    "begin", "end", "configuration::begin", "configuration::end",
    "installed", "package::begin", "package::end",
    "service::begin", "service::end", "service::started"].map {|item| "jboss::#{item}"}

  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_group 'jboss' }
    it { is_expected.to contain_user 'jboss' }
    it { is_expected.to contain_class 'jboss::params' }
    it { is_expected.to contain_class 'jboss::internal::configuration' }
    it { is_expected.to contain_jboss__interface('public') }
    it { is_expected.to contain_augeas('ensure present interface public') }
    it { is_expected.to contain_augeas('interface public set any-address') }

    anchor_list.each do |item|
      it { is_expected.to contain_anchor("#{item}") }
    end
    basic_bind_variables_list.each do |var|
      it { is_expected.to contain_augeas("interface public rm #{var}") }
      it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}") }
    end
    it { is_expected.to contain_jboss__internal__interface__foreach("public:any-address") }
    it { is_expected.to contain_service('wildfly').with({
      :ensure => 'running',
      :enable => true
      })}
    it { is_expected.to contain_exec('jboss::move-unzipped') }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-service' }
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
    let(:title) { 'test-module' }
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
