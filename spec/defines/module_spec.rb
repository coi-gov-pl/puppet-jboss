require 'spec_helper_puppet'

describe 'jboss::module', :type => :define do
  shared_examples 'contains self' do
    it { is_expected.to contain_class('jboss') }

    it {
      is_expected.to contain_jboss__internal__module__assemble(title).with(
        :layer        => 'jdbc',
        :artifacts    => ['https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar'],
        :dependencies => ['javax.transaction.api', 'javax.api']
      )
    }
    it {
      is_expected.to contain_jboss__module(title).with(
        :layer     => 'jdbc',
        :artifacts => ['https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar']
      )
    }
  end

  describe 'On RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-module' }
    let(:params) do
      {
        :layer        => 'jdbc',
        :artifacts    => ['https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar'],
        :dependencies => ['javax.transaction.api', 'javax.api']
      }
    end
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it_behaves_like 'contains self'
  end

  describe 'On Debian os family' do
    extend Testing::RspecPuppet::SharedExamples
    let(:title) { 'test-module' }
    let(:params) do
      {
        :layer        => 'jdbc',
        :artifacts    => ['https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar'],
        :dependencies => ['javax.transaction.api', 'javax.api']
      }
    end
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }

    it_behaves_like 'contains self'
  end
end
