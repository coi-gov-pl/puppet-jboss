require 'spec_helper_puppet'

describe 'jboss::deploy', :type => :define do
  shared_examples 'containing class structure' do
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::internal::runtime::node') }
    it {
      is_expected.to contain_jboss_deploy(title).with(
        :ensure => 'present',
        :source => '/tmp/jboss.war'
      )
    }
  end

  shared_examples 'containing self' do
    it {
      is_expected.to contain_jboss__deploy(title).with(
        :ensure => 'present',
        :jndi   => title
      )
    }
  end

  shared_examples 'raise error' do
    it {
      is_expected.to raise_error(
        Puppet::Error,
        /Invalid file extension, module only supports: .jar, .war, .ear, .rar/
      )
    }
  end

  context 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }
    context 'valid runtime_name' do
      let(:title) { 'test-deploy' }
      let(:params) do
        {
          :path         => '/tmp/jboss.war',
          :runtime_name => 'foobar-app.war'
        }
      end

      it_behaves_like 'containing class structure'
      it_behaves_like 'containing self'
    end

    context 'invalid runtime name' do
      let(:title) { 'test-deploy' }
      let(:params) do
        {
          :path         => '/tmp/jboss.war',
          :runtime_name => 'foobar-app'
        }
      end

      it_behaves_like 'raise error'
    end
  end

  context 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }

    context 'valid runtime_name' do
      let(:title) { 'test-deploy' }
      let(:params) { { :path => '/tmp/jboss.war' } }

      it_behaves_like 'containing class structure'
      it_behaves_like 'containing self'
    end

    context 'invalid runtime_name' do
      let(:title) { 'test-deploy' }
      let(:params) do
        {
          :path         => '/tmp/jboss.war',
          :runtime_name => 'foobar-app'
        }
      end

      it_behaves_like 'raise error'
    end
  end
end
