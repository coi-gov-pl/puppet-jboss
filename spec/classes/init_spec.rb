require 'spec_helper_puppet'

describe 'jboss', :type => :class do
  extend Testing::JBoss::SharedExamples
  extend Testing::RspecPuppet::Package
  let(:facts) do
    {
      :operatingsystem => 'OracleLinux',
      :osfamily        => 'RedHat',
      :ipaddress       => '192.168.0.1',
      :concat_basedir  => '/root/concat',
      :puppetversion   => Puppet.version
    }
  end

  context 'with defaults for all parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('jboss::internal::package') }
    it_behaves_like_full_working_jboss_installation
  end

  context 'with product => jboss-wildfly parameters set' do
    let(:product) { 'wildfly' }
    let(:version) { '8.2.0.Final' }
    let(:pre_condition) do
      "class { 'jboss': product => '#{product}', version => '#{version}' }"
    end
    it { is_expected.to compile }
    package_files_for_jboss_product
    package_exec_for_jboss
  end

  context 'with product => jboss-eap and version => 6.4.0.GA parameters set' do
    let(:product) { 'jboss-eap' }
    let(:version) { '6.4.0.GA' }
    let(:pre_condition) do
      "class { 'jboss': product => '#{product}', version => '#{version}' }"
    end
    it { is_expected.to compile }
    package_files_for_jboss_product({:product => 'jboss-eap', :version => '6.4.0.GA'})
  end

  context 'with product => jboss-eap and version => 6.2.0.GA parameters set' do
    let(:product) { 'jboss-eap' }
    let(:version) { '6.2.0.GA' }
    let(:pre_condition) do
      "class { 'jboss': product => '#{product}', version => '#{version}' }"
    end
    it { is_expected.to compile }
    package_files_for_jboss_product({:product => 'jboss-eap', :version => '6.2.0.GA'})
  end

  context 'with product => jboss-as and version => 7.1.0.Final parameters set' do
    let(:product) { 'jboss-as' }
    let(:version) { '7.1.0.Final' }
    let(:pre_condition) do
      "class { 'jboss': product => '#{product}', version => '#{version}' }"
    end
    it { is_expected.to compile }
    package_files_for_jboss_product({:product => 'jboss-as', :version => '7.1.0.Final'})
  end

  context 'with jboss_user => appserver parameter set' do
    let(:params) do
      { :jboss_user => 'appserver' }
    end
    it { is_expected.to compile }
  end

  context 'with download_url => file:///tmp/wildfly-8.2.0.Final.zip set' do
    let(:params) do
      { :download_url => 'file:///tmp/wildfly-8.2.0.Final.zip' }
    end

    it do
      is_expected.to contain_class('jboss').with({
        :download_url => 'file:///tmp/wildfly-8.2.0.Final.zip'
        })
    end
    it { is_expected.to contain_class 'jboss::params' }
    it { is_expected.to contain_class 'jboss::internal::compatibility' }
    it { is_expected.to contain_class 'jboss::internal::configuration' }
    it { is_expected.to contain_class 'jboss::internal::service' }

  end
end
