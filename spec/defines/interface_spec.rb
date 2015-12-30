require 'spec_helper_puppet'

describe 'jboss::interface', :type => :define do
  basic_bind_variables_list = [
    "any-address", "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual"
  ]
  legacy_bind_variables_list = [ "any-ipv4-address", "any-ipv6-address" ]

  let (:generic_facts) do
    {
      :operatingsystem => 'OracleLinux',
      :osfamily        => 'RedHat',
      :concat_basedir  => '/root/concat',
      :puppetversion   => Puppet.version,
    }
  end
  let(:title) { 'test-interface' }
  let(:facts) do
    generic_facts.merge(runtime_facts)
  end
  let(:basic_bind_variables) { Hash[basic_bind_variables_list.map {|x| [x, :undef]}] }
  let(:legacy_bind_variables) { Hash[legacy_bind_variables_list.map {|x| [x, :undef]}] }

  context 'with jboss_running => true and runasdomain => false parameters set' do
    let(:runtime_facts) do
      { :jboss_running => 'true' }
    end
    let(:params) do
      { :runasdomain => 'false' }
    end
    let(:pre_condition) { "class { jboss: product => '#{product}', version => '#{version}'}" }

    context 'with product => wildfly and version => 9.0.2.Final parameters set' do
      let(:product) {'wildfly'}
      let(:version) {'9.0.2.Final'}

      it { is_expected.to compile }
      it { is_expected.to contain_jboss__interface('test-interface') }
      it { is_expected.to contain_jboss__clientry('/interface=test-interface').with_properties(basic_bind_variables) }
    end
    context 'with product => wildfly and version => 8.2.1.Final parameters set' do
      let(:product) {'wildfly'}
      let(:version) {'8.2.1.Final'}

      it { is_expected.to compile }
      it { is_expected.to contain_jboss__interface('test-interface') }
      it { is_expected.to contain_jboss__clientry('/interface=test-interface').with_properties(
        basic_bind_variables.merge(legacy_bind_variables)
        )}
    end
  end

  context 'with jboss_running => false and runasdomain => false parameters set' do
    let(:runtime_facts) do
      { :jboss_running => 'false' }
    end
    let(:params) do
      { :runasdomain => 'false' }
    end
    let(:pre_condition) { "class { jboss: product => '#{product}', version => '#{version}'}" }
    context 'with product => wildfly and version => 9.0.2.Final parameters set' do
      let(:product) {'wildfly'}
      let(:version) {'9.0.2.Final'}

      it { is_expected.to compile }
      it { is_expected.to contain_jboss__interface('test-interface') }
      basic_bind_variables_list.each do |var|
        it { is_expected.to contain_augeas("interface test-interface rm #{var}") }
        it { is_expected.to contain_jboss__internal__interface__foreach("test-interface:#{var}").with_bind_variables(basic_bind_variables) }
      end
    end
    context 'with product => wildfly and version => 8.2.1.Final parameters set' do
      let(:product) {'wildfly'}
      let(:version) {'8.2.1.Final'}

      it { is_expected.to compile }
      it { is_expected.to contain_jboss__interface('test-interface') }
      basic_bind_variables_list.each do |var|
        it { is_expected.to contain_augeas("interface test-interface rm #{var}") }
        it { is_expected.to contain_jboss__internal__interface__foreach("test-interface:#{var}").with_bind_variables(
          basic_bind_variables.merge(legacy_bind_variables)
          )}
      end
      legacy_bind_variables_list.each do |var|
        it { is_expected.to contain_augeas("interface test-interface rm #{var}") }
        it { is_expected.to contain_jboss__internal__interface__foreach("test-interface:#{var}").with_bind_variables(
          basic_bind_variables.merge(legacy_bind_variables)
          )}
      end
    end
    context 'with product => jboss-eap and version => 7.0.0.Beta parameters set' do
      let(:product) {'jboss-eap'}
      let(:version) {'7.0.0.Beta'}

      it { is_expected.to compile }
      it { is_expected.to contain_jboss__interface('test-interface') }
      basic_bind_variables_list.each do |var|
        it { is_expected.to contain_augeas("interface test-interface rm #{var}") }
        it { is_expected.to contain_jboss__internal__interface__foreach("test-interface:#{var}").with_bind_variables(basic_bind_variables) }
      end
    end
  end

end
