require 'spec_helper_puppet'

describe 'Puppet::Type::Jboss_datasource::ProviderJbosscli' do
  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999',
      :home       => '/usr/share/jb-78'
    }
  end

  before :each do
    PuppetX::Coi::Jboss::Configuration.reset_config(mock_values)
    expect(Puppet).not_to receive(:err)
  end
  after :each do
    PuppetX::Coi::Jboss::Configuration.reset_config
    executor.verify_commands_executed
  end
  let(:described_class) do
    Puppet::Type.type(:jboss_datasource).provider(:jbosscli)
  end
  let(:sample_repl) do
    {
      :name        => 'testing',
      :xa          => false,
      :runasdomain => false,
      :jdbcscheme  => 'h2:mem'
    }
  end

  let(:resource) do
    raw = sample_repl.dup
    raw[:provider] = described_class.name
    Puppet::Type.type(:jboss_datasource).new(raw)
  end

  let(:executor) { Testing::Mock::ExecutionStateWrapper.new }

  let(:provider) do
    provider = resource.provider
    provider.executor(executor)
    provider
  end

  describe 'Given `testing` Non-XA datasource using h2:mem' do
    let(:command) do
      '/subsystem=datasources/data-source=testing:read-resource(recursive=true)'
    end
    let(:runasdomain) { false }
    let(:timeout) { 0 }
    let(:retry_count) { 0 }
    let(:ctrlcfg) do
      {
        :controller => '127.0.0.1:9990',
        :ctrluser   => nil,
        :ctrlpasswd => nil
      }
    end
    let(:result) do
      {
        'outcome' => 'success',
        'result'  => {
          'allocation-retry'                    => nil,
          'allocation-retry-wait-millis'        => nil,
          'allow-multiple-users'                => false,
          'background-validation'               => false,
          'background-validation-millis'        => nil,
          'blocking-timeout-wait-millis'        => nil,
          'capacity-decrementer-class'          => nil,
          'capacity-decrementer-properties'     => nil,
          'capacity-incrementer-class'          => nil,
          'capacity-incrementer-properties'     => nil,
          'check-valid-connection-sql'          => nil,
          'connection-listener-class'           => nil,
          'connection-listener-property'        => nil,
          'connection-properties'               => nil,
          'connection-url'                      => 'jdbc:h2:mem:///testing;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE',
          'datasource-class'                    => nil,
          'driver-class'                        => nil,
          'driver-name'                         => 'h2',
          'enabled'                             => true,
          'exception-sorter-class-name'         => nil,
          'exception-sorter-properties'         => nil,
          'flush-strategy'                      => nil,
          'idle-timeout-minutes'                => nil,
          'initial-pool-size'                   => nil,
          'jndi-name'                           => 'java:jboss/datasources/testing',
          'jta'                                 => true,
          'max-pool-size'                       => 50,
          'min-pool-size'                       => 1,
          'new-connection-sql'                  => nil,
          'password'                            => 'test-password',
          'pool-prefill'                        => nil,
          'pool-use-strict-min'                 => nil,
          'prepared-statements-cache-size'      => 0,
          'query-timeout'                       => nil,
          'reauth-plugin-class-name'            => nil,
          'reauth-plugin-properties'            => nil,
          'security-domain'                     => nil,
          'set-tx-query-timeout'                => false,
          'share-prepared-statements'           => false,
          'spy'                                 => false,
          'stale-connection-checker-class-name' => nil,
          'stale-connection-checker-properties' => nil,
          'track-statements'                    => 'NOWARN',
          'transaction-isolation'               => nil,
          'url-delimiter'                       => nil,
          'url-selector-strategy-class-name'    => nil,
          'use-ccm'                             => true,
          'use-fast-fail'                       => false,
          'use-java-context'                    => true,
          'use-try-lock'                        => nil,
          'user-name'                           => 'test-username',
          'valid-connection-checker-class-name' => nil,
          'valid-connection-checker-properties' => nil,
          'validate-on-match'                   => false,
          'statistics'                          => nil
        }
      }
    end
    let(:expected_connection) do
      'testing;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE'
    end
    before :each do
      executor.register_command(
        '/subsystem=datasources/data-source=testing:read-resource(recursive=true)',
        result
      )
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

  describe 'For XA Datasource' do
    let(:sample_repl) do
      {
        :name        => 'testing',
        :xa          => true,
        :runasdomain => false,
        :jdbcscheme  => 'h2:mem',
        :options     => datasource_options,
        :jndiname    => 'jboss:/datasources/testing'
      }
    end
    let(:datasource_options) { {} }
    let(:result) do
      {
        'outcome' => 'success',
        'result'  => {
          'jta' => false
        }.merge(datasource_options)
      }
    end
    before :each do
      executor.register_command(
        '/subsystem=datasources/xa-data-source=testing:read-resource(recursive=true)',
        result
      )
      provider.exists?
    end
    describe 'while using JBoss EAP 6.4.0.GA' do
      describe 'jta()' do
        subject { provider.jta }
        it { expect(subject).not_to be_nil }
        it { expect(subject).to eq('true') }
      end
      describe 'jta_opt(cmd)' do
        before :each do
          provider.jta = true
        end
        let(:cmd) { [] }
        subject { provider.jta_opt(cmd) }
        it { expect(subject).to be_nil }
        it { expect(cmd).to be_empty }
      end

      describe '#options=(new_options)' do
        let(:datasource_options) do
          {
            'xa-some-opt' => 'true',
            'sample-opt'  => 'gigabyte'
          }
        end
        let(:datasource_options_setattrb_response) do
          { 'outcome' => 'success', 'result' => {} }
        end
        before :each do
          nil
        end
        subject { provider.options = new_options }
        shared_examples 'options was set' do
          it { expect { subject }.not_to raise_error }
        end
        describe 'with new_options equal to { "xa-some-opt" => false }' do
          let(:new_options) do
            { 'xa-some-opt' => false, 'sample-opt' => 'gigabyte' }
          end
          before :each do
            executor.register_command(
              '/subsystem=datasources/xa-data-source=testing:write-attribute(name="xa-some-opt", value=false)',
              datasource_options_setattrb_response
            )
          end
          it_behaves_like 'options was set'
        end
        describe 'for cases that undefines setted values' do
          before :each do
            datasource_options.keys.each do |key|
              executor.register_command(
                "/subsystem=datasources/xa-data-source=testing:undefine-attribute(name=\"#{key}\")",
                datasource_options_setattrb_response
              )
            end
          end
          describe 'with new_options equal to :absent' do
            let(:new_options) { :absent }
            it_behaves_like 'options was set'
          end
          describe 'with new_options equal to :undef' do
            let(:new_options) { :undef }
            it_behaves_like 'options was set'
          end
          describe 'with new_options equal to nil' do
            let(:new_options) { nil }
            it_behaves_like 'options was set'
          end
        end
      end
    end
    describe 'while using JBoss EAP 6.2.0.GA' do
      let(:mock_values) do
        {
          :product    => 'jboss-eap',
          :version    => '6.2.0.GA',
          :controller => '127.0.0.1:9999',
          :home       => '/usr/share/eap-7'
        }
      end
      describe 'jta()' do
        subject { provider.jta }
        it { expect(subject).not_to be_nil }
        it { expect(subject).to eq('false') }
      end
      describe 'jta_opt(cmd)' do
        before :each do
          executor.register_command(
            '/subsystem=datasources/xa-data-source=testing:write-attribute(name="jta", value="true")',
            {
              'outcome' => 'success',
              'result'  => {}
            }
          )
          provider.jta = true
        end
        let(:cmd) { [] }
        subject { provider.jta_opt(cmd) }
        it { expect(subject).not_to be_nil }
        it { expect(cmd).to be_empty }
      end

      describe 'create()' do
        before :each do
          cmd = 'xa-data-source add --name=testing --jta=true --jndi-name="jboss:/datasources/testing" ' \
                '--driver-name=nil --min-pool-size=nil --max-pool-size=nil' \
                ' --user-name=nil --password=nil --xa-datasource-properties=' \
                '[ServerName=nil,PortNumber=nil,DatabaseName="testing"]'
          executor.register_command(cmd)
          executor.register_command(
            '/subsystem=datasources/xa-data-source=testing:read-attribute(name=enabled)',
            {
              'outcome' => 'success',
              'result'  => true
            }
          )
        end
        subject { provider.create }
        it { expect { subject }.not_to raise_error }
      end

      describe 'destroy()' do
        before :each do
          executor.register_command(
            'xa-data-source remove --name=testing'
          )
        end
        subject { provider.destroy }
        it { expect { subject }.not_to raise_error }
      end
    end
  end

  describe 'prepare_resource()' do
    before :each do
      provider.instance_variable_set(:@resource, nil)
    end
    subject { provider.prepare_resource }
    it { expect { subject }.not_to raise_error }
  end
end
