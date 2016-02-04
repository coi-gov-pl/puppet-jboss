require 'spec_helper_puppet'

describe 'jboss::internal::augeas', :type => :class do
  wildfly = '8.2.0.Final'
  bind_variables_list = [
    "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual",
    "any-ipv4-address", "any-ipv6-address" ]

  anchor_list = [
    "begin", "end", "configuration::begin", "configuration::end",
    "installed", "package::begin", "package::end",
    "service::begin", "service::end", "service::started"].map {|item| "jboss::#{item}"}

  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_class 'jboss::internal::lenses' }
    it { is_expected.to contain_class 'jboss::internal::augeas' }

    it { is_expected.to contain_jboss__interface('public').with ({
      :ensure       => 'present',
      :inet_address => nil
      }) }
    it { is_expected.to contain_augeas('ensure present interface public').with ({
      :context => "/files/usr/lib/wildfly-#{wildfly}/standalone/configuration/standalone-full.xml/",
      :changes => "set server/interfaces/interface[last()+1]/#attribute/name public",
      :onlyif  => "match server/interfaces/interface[#attribute/name='public'] size == 0"
      }) }
    it { is_expected.to contain_augeas('interface public set any-address').with ({
      :context => "/files/usr/lib/wildfly-#{wildfly}/standalone/configuration/standalone-full.xml/",
      :changes => "set server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value 'true'",
      :onlyif  => "get server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value != 'true'"
      }) }
    it { is_expected.to contain_jboss__internal__interface__foreach("public:any-address").with ({
      :cfg_file => "/usr/lib/wildfly-#{wildfly}/standalone/configuration/standalone-full.xml",
      :path     => 'server/interfaces'
      }) }

    anchor_list.each do |item|
      it { is_expected.to contain_anchor("#{item}") }
    end

    bind_variables_list.each do |var|
      it { is_expected.to contain_augeas("interface public rm #{var}").with ({
        :context => "/files/usr/lib/wildfly-#{wildfly}/standalone/configuration/standalone-full.xml/",
        :changes => "rm server/interfaces/interface[#attribute/name='public']/#{var}",
        :onlyif  => "match server/interfaces/interface[#attribute/name='public']/#{var} size != 0"
        }) }
      it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}").with ({
        :cfg_file => "/usr/lib/wildfly-#{wildfly}/standalone/configuration/standalone-full.xml",
        :path     => 'server/interfaces'
        }) }
      end
    it { is_expected.to contain_service('wildfly').with ({
      :ensure => 'running',
      :enable => true
      }) }

    it { is_expected.to contain_file("/usr/lib/wildfly-8.2.0.Final/lenses/jbxml.aug") }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-augeas' }
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
    let(:title) { 'test-augeas' }
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
