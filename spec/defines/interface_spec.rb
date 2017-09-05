require 'spec_helper_puppet'

describe 'jboss::interface', :type => :define do

  shared_examples 'basic class structure' do
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::internal::augeas') }
    it { is_expected.to contain_class('jboss::internal::runtime') }
  end

  basic_bind_variables_list = [
    "inet-address", "link-local-address",
    "loopback", "loopback-address", "multicast",
    "nic", "nic-match", "point-to-point", "public-address",
    "site-local-address", "subnet-match", "up", "virtual"
  ]
  legacy_bind_variables_list = [ "any-ipv4-address", "any-ipv6-address" ]

  let(:title)  { 'test-interface' }

  let(:generic_params)        {{ :any_address => 'true', :runasdomain => true, :controller => '127.0.0.1', :profile => 'full' } }
  let(:any_addr_property)     {{ 'any-address' => 'true' }}
  let(:basic_bind_variables)  { Hash[basic_bind_variables_list.map {|x| [x, :undef]}] }
  let(:legacy_bind_variables) { Hash[legacy_bind_variables_list.map {|x| [x, :undef]}] }

  shared_examples 'completly working define' do
    let(:facts)  { generic_facts.merge({ :jboss_running => 'false' })}
    it { is_expected.to contain_jboss__interface(title) }
    it { is_expected.to contain_augeas("ensure present interface #{title}") }
    it { is_expected.to contain_augeas("interface #{title} set any-address") }
    it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:any-address") }
    basic_bind_variables_list.each do |var|
      it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
      it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}") }
    end
  end

  shared_examples 'a define with properly configured interface' do
    context 'with jboss_running => true and runasdomain => false parameters set' do
      let(:facts)  { generic_facts.merge({ :jboss_running => 'true' })}
      let(:params) { generic_params.merge({ :runasdomain => 'false' })}
      let(:pre_condition)  { "class { jboss: product => '#{product}', version => '#{version}'}" }

      context 'with product => wildfly and version => 9.0.2.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'9.0.2.Final'}

        it { is_expected.to contain_jboss__clientry("/interface=#{title}").with_properties(
          basic_bind_variables.merge(any_addr_property)
          )}
      end
      context 'with product => wildfly and version => 8.2.1.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'8.2.1.Final'}

        it { is_expected.to contain_jboss__clientry("/interface=#{title}").with_properties(
          basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
          )}
      end
      context 'with product => jboss-eap and version => 7.0.0.Beta parameters set' do
        let(:product) {'jboss-eap'}
        let(:version) {'7.0.0.Beta'}

        it { is_expected.to contain_jboss__clientry("/interface=#{title}").with_properties(
          basic_bind_variables.merge(any_addr_property)
          )}
      end
      context 'with product => wildfly and version => 15.0.0.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'15.0.0.Final'}

        it { is_expected.to raise_error(Puppet::Error, /Unsupported version wildfly 15.0.0.Final/) }
      end
    end

    context 'with jboss_running => false and runasdomain => false parameters set' do
      let(:facts)  { generic_facts.merge({ :jboss_running => 'false' })}
      let(:params) { generic_params.merge({ :runasdomain => 'false' })}
      let(:pre_condition)  { "class { jboss: product => '#{product}', version => '#{version}'}" }

      context 'with product => wildfly and version => 9.0.2.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'9.0.2.Final'}

        basic_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(any_addr_property)
            )}
        end
      end
      context 'with product => wildfly and version => 8.2.1.Final parameters set' do
        let(:product) {'wildfly'}
        let(:version) {'8.2.1.Final'}

        basic_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
            )}
        end
        legacy_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_augeas("interface public rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
            )}
          it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}").with_bind_variables(
            basic_bind_variables.merge(legacy_bind_variables).merge(any_addr_property)
            )}
        end
      end
      context 'with product => jboss-eap and version => 7.0.0.Beta parameters set' do
        let(:product) {'jboss-eap'}
        let(:version) {'7.0.0.Beta'}

        basic_bind_variables_list.each do |var|
          it { is_expected.to contain_augeas("interface #{title} rm #{var}") }
          it { is_expected.to contain_jboss__internal__interface__foreach("#{title}:#{var}").with_bind_variables(
            basic_bind_variables.merge(any_addr_property)
            )}
        end
      end
    end
  end

  context 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:generic_facts) do
      {
        :operatingsystem => 'OracleLinux',
        :osfamily        => 'RedHat',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :puppetversion   => Puppet.version,
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :operatingsystemrelease    => '6.7',
        :virtual                   => true,
        :jboss_running             => true,
        :architecture              => 'amd64'

      }
    end
    let(:facts) {generic_facts}
    let(:params) {generic_params}

    it_behaves_like 'basic class structure'

    it_behaves_like 'completly working define'
    it_behaves_like 'a define with properly configured interface'
  end

  context 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:generic_facts) do
      {
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :lsbdistcodename => 'trusty',
        :puppetversion   => Puppet.version,
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :operatingsystemrelease    => '14.04',
        :virtual                   => true,
        :jboss_running             => true,
        :architecture              => 'amd64'

      }
    end
    let(:facts) {generic_facts}
    let(:params) {generic_params}

    it_behaves_like 'completly working define'
    it_behaves_like 'a define with properly configured interface'
  end
end
