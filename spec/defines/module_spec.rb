require 'spec_helper_puppet'

describe 'jboss::module', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to contain_jboss__internal__module__assemble(title).with({
      :layer        => 'jdbc',
      :artifacts    => ["https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar"],
      :dependencies => ["javax.transaction.api", "javax.api"]
    })}
    it { is_expected.to contain_jboss__module(title).with({
      :layer        => 'jdbc',
      :artifacts    => ["https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar"]
      }) }
  end

  context 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-module' }
    let(:params) do
      {
        :layer        => 'jdbc',
        :artifacts    => ['https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar'],
        :dependencies => ['javax.transaction.api', 'javax.api']
      }
    end
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
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-module' }
    let(:params) do
      {
        :layer        => 'jdbc',
        :artifacts    => ['https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar'],
        :dependencies => ['javax.transaction.api', 'javax.api']
      }
    end
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
