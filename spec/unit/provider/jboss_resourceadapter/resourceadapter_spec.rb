require 'spec_helper_puppet'

describe 'Puppet::Type::Jboss_confignode::ProviderJbosscli' do
  let(:described_class) do
    Puppet::Type.type(:jboss_confignode).provider(:jbosscli)
  end
  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999',
      :home       => '/usr/lib/jboss-17.3'
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

  let(:sample_repl) do
    {
      :name               => 'genericconnector.rar',
      :archive            => 'genericconnector.rar',
      :transactionsupport => 'XATransaction',
      :classname          => 'ch.maxant.generic_jca_adapter.ManagedTransactionAssistanceFactory',
      :jndiname           => 'java:/jboss/jca-generic'
    }
  end
  let(:extended_repl) { {} }
  let(:raw) { sample_repl.merge(extended_repl) }
  let(:data) { Hash[raw.collect { |k, v| [k.to_s, v] }] }
  let(:resource) do
    props = raw
    props[:provider] = described_class.name
    Puppet::Type.type(:jboss_resourceadapter).new(props)
  end

  let(:executor) { Testing::Mock::ExecutionStateWrapper.new }

  let(:provider) do
    provider = resource.provider
    provider.executor(executor)
    provider
  end

  let(:clipath) { '/profile=full/subsystem=resource-adapters' }

  let(:loaded_data) do
    {
      'archive'                => 'genericconnector.rar',
      'transaction-support'    => 'XATransaction',
      'connection-definitions' => {
        'java:/jboss/jca-generic' => {
          'class-name' => 'ch.maxant.generic_jca_adapter.ManagedTransactionAssistanceFactory',
          'jndi-name'  => 'java:/jboss/jca-generic'
        }
      }
    }
  end

  describe '#exists?' do
    subject { provider.exists? }
    describe 'on existing resource' do
      before :each do
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"
        executor.register_command(cmd)
      end
      it { expect(subject).to eq(true) }
    end

    describe 'on absent resource' do
      before :each do
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"
        executor.register_failing_command(cmd)
      end
      it { expect(subject).to eq(false) }
    end
  end

  describe '#create' do
    subject { provider.create }
    before :each do
      cmd = "#{clipath}/resource-adapter=genericconnector.rar:add(archive=\"genericconnector.rar\", transaction-support=\"XATransaction\")"
      executor.register_command(cmd)
      cmd2 = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"
      expected_output = {
        'outcome' => 'success',
        'result'  => {
          'archive'                => 'genericconnector.rar',
          'transaction-support'    => 'XATransaction',
          'connection-definitions' => {}
        }
      }
      executor.register_command(cmd2, expected_output)
      cmd3 = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-generic:read-resource()"
      executor.register_failing_command(cmd3)
      params = [
        'background-validation=true',
        'class-name="ch.maxant.generic_jca_adapter.ManagedTransactionAssistanceFactory"',
        'jndi-name="java:/jboss/jca-generic"',
        'security-application=true'
      ].join ', '
      cmd4 = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-generic:add(#{params})"
      executor.register_command(cmd4)
    end
    it { expect(subject).to be(:created) }
  end

  describe '#destroy' do
    subject { provider.destroy }
    before :each do
      cmd = "#{clipath}/resource-adapter=genericconnector.rar:remove()"
      executor.register_command(cmd)
    end
    it { expect(subject).to be(:destroyed) }
  end

  describe 'managed properties' do
    before :each do
      cmd = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"
      executor.register_command(
        cmd,
        'outcome' => 'success',
        'result'  => loaded_data
      )
      provider.exists?
    end
    describe '#jndiname=' do
      let(:jndi_to_set) { ['java:/jboss/jca-xtra'] }
      subject do
        provider.jndiname = jndi_to_set
      end
      let(:extended_repl) do
        { :jndiname => 'java:/jboss/jca-xtra' }
      end
      before :each do
        cmd = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-generic:remove()"
        executor.register_command(cmd)
        params = [
          'background-validation=true',
          'class-name="ch.maxant.generic_jca_adapter.ManagedTransactionAssistanceFactory"',
          'jndi-name="java:/jboss/jca-xtra"',
          'security-application=true'
        ].join ', '
        cmd = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-xtra:add(#{params})"
        executor.register_command(cmd)
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"
        executor.register_command(cmd)
      end
      it { expect(subject).to eq(['java:/jboss/jca-xtra']) }
    end

    describe '#archive' do
      subject { provider.archive }
      it { expect(subject).to eq('genericconnector.rar') }
    end

    describe '#archive=' do
      subject { provider.archive = 'xa-connector.rar' }
      before :each do
        op = 'write-attribute(name="archive", value="xa-connector.rar")'
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:#{op}"
        executor.register_command(cmd)
      end
      it { expect(subject).to eq('xa-connector.rar') }
    end

    describe '#security' do
      subject { provider.security }
      let(:ext_loaded_data) do
        {
          'connection-definitions' => {
            'java:/jboss/jca-generic' => {
              'jndi-name' => 'java:/jboss/jca-generic'
            }
          }
        }
      end

      describe 'security-application' do
        let(:loaded_data) do
          ext_loaded_data.merge(
            'connection-definitions' => {
              'java:/jboss/jca-generic' => {
                'security-application' => 'true'
              }
            }
          )
        end
        it { expect(subject).to eq('application') }
      end

      describe 'security-domain-and-application' do
        let(:loaded_data) do
          ext_loaded_data.merge(
            'connection-definitions' => {
              'java:/jboss/jca-generic' => {
                'security-domain-and-application' => 'true'
              }
            }
          )
        end
        it { expect(subject).to eq('domain-and-application') }
      end

      describe 'security-domain' do
        let(:loaded_data) do
          ext_loaded_data.merge(
            'connection-definitions' => {
              'java:/jboss/jca-generic' => {
                'security-domain' => 'true'
              }
            }
          )
        end
        it { expect(subject).to eq('domain') }
      end
    end

    describe '#security=' do
      subject { provider.security = value }
      let(:loaded_data) do
        {
          'connection-definitions' => {
            'java:/jboss/jca-generic' => {
              'jndi-name' => 'java:/jboss/jca-generic'
            }
          }
        }
      end

      describe 'security-application' do
        let(:value) { 'application' }
        before(:each) do
          op = 'write-attribute(name="security-application", value=true)'
          el = 'connection-definitions=java\:\/jboss\/jca-generic'
          cmd = "#{clipath}/resource-adapter=genericconnector.rar/#{el}:#{op}"
          executor.register_command(cmd)
          op = 'undefine-attribute(name=security-domain-and-application)'
          cmd = "#{clipath}/resource-adapter=genericconnector.rar/#{el}:#{op}"
          executor.register_command(cmd)
          op = 'undefine-attribute(name=security-domain)'
          cmd = "#{clipath}/resource-adapter=genericconnector.rar/#{el}:#{op}"
          executor.register_command(cmd)
        end
        it { expect(subject).to eq('application') }
      end
    end
  end
end
