require 'spec_helper_puppet'

describe 'jboss::internal::quirks::etc_initd_functions', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to contain_class 'jboss::internal::quirks::etc_initd_functions' }
  end

  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-etc_initd_functions' }
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
    it_behaves_like_full_working_jboss_installation

  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-etc_initd_functions' }
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
    it_behaves_like_full_working_jboss_installation

  end
end
