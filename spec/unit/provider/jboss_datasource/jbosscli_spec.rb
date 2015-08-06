require 'spec_helper'
require 'puppet_x/coi/jboss/configuration'

context "While mocking facts :jboss_product => 'jboss-eap' and :jboss_version => '6.4.0.GA'" do
  
  mock_values = {
    :product    => 'jboss-eap',
    :version    => '6.4.0.GA',
    :controller => '127.0.0.1:9999',
  }
  
  Puppet_X::Coi::Jboss::Configuration.reset_config(mock_values)
  
  before :each do
    Puppet_X::Coi::Jboss::Configuration.reset_config(mock_values)
  end
  
  after :each do
    Puppet_X::Coi::Jboss::Configuration.reset_config
  end

  describe Puppet::Type.type(:jboss_datasource).provider(:jbosscli) do
  
    let(:sample_repl) do
      {
        :name        => 'testing',
        :xa          => false,
        :runasdomain => false,
        :jdbcscheme  => 'h2:mem',
      }
    end
  
    let(:resource) do
      raw = sample_repl.dup
      raw[:provider] = described_class.name
      Puppet::Type.type(:jboss_datasource).new(raw)
    end
  
    let(:provider) do
      resource.provider
    end
  
    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
    end
  
    describe 'Result of self.instances()' do
      let(:xa_result) do
        <<-eos
        {
          "outcome" => "success",
          "result" => []
        }
        eos
      end
      let(:nonxa_result) do
        <<-eos
        {
            "outcome" => "success",
            "result" => [
                "ExampleDS",
                "test-datasource"
            ]
        }
        eos
      end
      let(:status) { double(:exitstatus => 0) }
      let(:exec_options) { { :failonfail=>false, :combine=>true } }
      before :each do
        re = /.*bin\/jboss-cli.sh --timeout=50000 --connect --file=\/tmp\/jbosscli.* --controller=127.0.0.1:9999/
        expect(Puppet::Provider::Jbosscli).to receive(:last_execute_status).
          at_least(:once).and_return(status)
        expect(Puppet::Util::Execution).to receive(:execute).
          at_least(:once).with(re, exec_options).and_return(xa_result, nonxa_result)
      end
      it { expect(provider.class.instances).not_to be_empty }
      context 'its size' do
        subject { provider.class.instances.size }
        it { expect(subject).to eq(2) }  
      end
      context 'for second result, parameter' do
        subject { provider.class.instances[1] }
        its(:class) { should eq(Puppet::Type::Jboss_datasource::ProviderJbosscli) }
        its(:name) { should eq('test-datasource') }
        its(:xa) { should eq(false) }
      end
    end
    
    context 'Given `testing` Non-XA datasource using h2:mem' do
      let(:command) do
        '/subsystem=datasources/data-source=testing:read-resource(recursive=true)'
      end
      let(:runasdomain) { false }
      let(:timeout) { 0 }
      let(:retry_count) { 0 }
      let(:ctrlcfg) do
        { 
          :controller => "127.0.0.1:9990",
          :ctrluser   => nil,
          :ctrlpasswd => nil
        }
      end
      let(:result) do
        {
          :result => true,
          :data   => {
            "allocation-retry" => nil,
            "allocation-retry-wait-millis" => nil,
            "allow-multiple-users" => false,
            "background-validation" => false,
            "background-validation-millis" => nil,
            "blocking-timeout-wait-millis" => nil,
            "capacity-decrementer-class" => nil,
            "capacity-decrementer-properties" => nil,
            "capacity-incrementer-class" => nil,
            "capacity-incrementer-properties" => nil,
            "check-valid-connection-sql" => nil,
            "connection-listener-class" => nil,
            "connection-listener-property" => nil,
            "connection-properties" => nil,
            "connection-url" => "jdbc:h2:mem:///testing;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE",
            "datasource-class" => nil,
            "driver-class" => nil,
            "driver-name" => "h2",
            "enabled" => true,
            "exception-sorter-class-name" => nil,
            "exception-sorter-properties" => nil,
            "flush-strategy" => nil,
            "idle-timeout-minutes" => nil,
            "initial-pool-size" => nil,
            "jndi-name" => "java:jboss/datasources/testing",
            "jta" => true,
            "max-pool-size" => 50,
            "min-pool-size" => 1,
            "new-connection-sql" => nil,
            "password" => "test-password",
            "pool-prefill" => nil,
            "pool-use-strict-min" => nil,
            "prepared-statements-cache-size" => 0,
            "query-timeout" => nil,
            "reauth-plugin-class-name" => nil,
            "reauth-plugin-properties" => nil,
            "security-domain" => nil,
            "set-tx-query-timeout" => false,
            "share-prepared-statements" => false,
            "spy" => false,
            "stale-connection-checker-class-name" => nil,
            "stale-connection-checker-properties" => nil,
            "track-statements" => "NOWARN",
            "transaction-isolation" => nil,
            "url-delimiter" => nil,
            "url-selector-strategy-class-name" => nil,
            "use-ccm" => true,
            "use-fast-fail" => false,
            "use-java-context" => true,
            "use-try-lock" => nil,
            "user-name" => "test-username",
            "valid-connection-checker-class-name" => nil,
            "valid-connection-checker-properties" => nil,
            "validate-on-match" => false,
            "statistics" => nil
          }
        }
      end
      let(:expected_connection) do
        "testing;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
      end
      before :each do
        expect(Puppet::Provider::Jbosscli).to receive(:executeAndGet).
          with(command, runasdomain, ctrlcfg, retry_count, timeout).and_return(result)
      end
    
      describe 'result of dbname()' do
        subject { provider.dbname }
        it { expect(subject).not_to be_nil }
        it { expect(subject).not_to be_empty }
        it { expect(subject).to eq(expected_connection) }
      end
      
      describe 'result of host()' do
        subject { provider.host }
        it { expect(subject).not_to be_nil }
        it { expect(subject).to be_empty }
        it { expect(subject).to eq('') }
      end
      
      describe 'result of port()' do
        subject { provider.port }
        it { expect(subject).not_to be_nil }
        it { expect(subject).to eq(0) }
      end
      
      describe 'result of jdbcscheme()' do
        subject { provider.jdbcscheme }
        it { expect(subject).not_to be_nil }
        it { expect(subject).not_to be_empty }
        it { expect(subject).to eq('h2:mem') }
      end
    end
  end
end