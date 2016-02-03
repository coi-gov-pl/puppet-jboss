require 'spec_helper_puppet'

describe 'jboss::clientry', :type => :define do
  basic_bind_variables_list = [
    "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual" ]

  anchor_list = [
    "begin", "end", "configuration::begin", "configuration::end",
    "installed", "package::begin", "package::end",
    "service::begin", "service::end", "service::started"].map {|item| "jboss::#{item}"}

  cfg_file = "/usr/lib/wildfly-9.0.2.Final/standalone/configuration/standalone-full.xml"

  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_jboss_confignode(title).with ({
      :ensure => 'present',
      :path   => 'profile/test'
      }) }

    it { is_expected.to contain_user 'jboss' }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_group 'jboss' }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class 'jboss::internal::runtime::node' }
    it { is_expected.to contain_class 'jboss::params' }
    it { is_expected.to contain_class 'jboss::internal::runtime::dc' }
    it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
    it { is_expected.to contain_jboss_confignode(title).that_requires('Anchor[jboss::package::end]') }
    it { is_expected.to contain_jboss__clientry(title).with ({
      :ensure => 'present',
      :path   => 'profile/test',
      }) }
    it { is_expected.to contain_jboss__interface('public').with ({
      :ensure       => 'present',
      :inet_address => nil
      }) }
    it { is_expected.to contain_augeas('ensure present interface public').with ({
        :context => "/files#{cfg_file}/",
        :changes => "set server/interfaces/interface[last()+1]/#attribute/name public",
        :onlyif  => "match server/interfaces/interface[#attribute/name='public'] size == 0"
        }) }
    it { is_expected.to contain_augeas('interface public set any-address').with ({
      :context => "/files#{cfg_file}/",
      :changes => "set server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value 'true'",
      :onlyif  => "get server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value != 'true'"
      }) }
    it { is_expected.to contain_jboss__internal__interface__foreach("public:any-address").with ({
      :cfg_file => cfg_file,
      :path     => 'server/interfaces'
      }) }

    anchor_list.each do |item|
      it { is_expected.to contain_anchor("#{item}") }
    end

    basic_bind_variables_list.each do |var|
      it { is_expected.to contain_augeas("interface public rm #{var}").with ({
        :context => "/files#{cfg_file}/",
        :changes => "rm server/interfaces/interface[#attribute/name='public']/#{var}",
        :onlyif  => "match server/interfaces/interface[#attribute/name='public']/#{var} size != 0"
        }) }
      it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}").with ({
        :cfg_file => cfg_file,
        :path     => 'server/interfaces'
        }) }
    end
    it { is_expected.to contain_service('wildfly').with ({
      :ensure => 'running',
      :enable => true
      }) }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-clientry' }
    let(:params) { { :path => 'profile/test', } }
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
    let(:title) { 'test-clientry' }
    let(:params) { { :path => 'profile/test', } }
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
