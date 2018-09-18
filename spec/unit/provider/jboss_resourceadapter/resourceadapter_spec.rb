require 'spec_helper_puppet'

describe 'Puppet::Type::Jboss_confignode::ProviderJbosscli' do
  let(:described_class) do
    Puppet::Type.type(:jboss_confignode).provider(:jbosscli)
  end
  describe 'with mocked configuration options to jboss-eap 6.4.0.GA' do
    let(:mock_values) do
      {
        :product    => 'jboss-eap',
        :version    => '6.4.0.GA',
        :controller => '127.0.0.1:9999'
      }
    end

    before :each do
      PuppetX::Coi::Jboss::Configuration.reset_config(mock_values)
    end

    after :each do
      PuppetX::Coi::Jboss::Configuration.reset_config
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

    let(:extended_repl) do
      {}
    end

    let(:resource) do
      raw = sample_repl.merge(extended_repl)
      raw[:provider] = described_class.name

      Puppet::Type.type(:jboss_resourceadapter).new(raw)
    end

    let(:provider) do
      resource.provider
    end

    let(:loaded_data) { nil }

    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
      provider.instance_variable_set(:@data, loaded_data)
    end

    let(:clipath) { '/profile=full/subsystem=resource-adapters' }

    describe '#exists?' do
      subject { provider.exists? }
      describe 'on existing resource' do
        before :each do
          cmd = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"

          expected_output = {
            :result => true,
            :data   => {}
          }
          expect(provider).to receive(:execute_and_get).with(cmd).and_return(expected_output)
        end
        it { expect(subject).to eq(true) }
      end

      describe 'on absent resource' do
        before :each do
          cmd = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"

          expected_output = {
            :result => false
          }
          expect(provider).to receive(:execute_and_get).with(cmd).and_return(expected_output)
        end
        it { expect(subject).to eq(false) }
      end
    end

    describe '#create' do
      subject { provider.create }
      before :each do
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:add(archive=\"genericconnector.rar\", transaction-support=\"XATransaction\")"
        expect(provider).to receive(:execute_with_fail).with(
          'Resource adapter',
          cmd,
          'to create'
        )
        cmd2 = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"
        expected_output = {
          :result => true,
          :data   => {
            'archive'                => 'genericconnector.rar',
            'transaction-support'    => 'XATransaction',
            'connection-definitions' => {}
          }
        }
        expect(provider).to receive(:execute_and_get).with(cmd2).and_return(expected_output)
        cmd3 = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-generic:read-resource()"
        expected_output = {
          :result => false
        }
        expect(provider).to receive(:execute_and_get).with(cmd3).and_return(expected_output)
        params = [
          'background-validation=true',
          'class-name="ch.maxant.generic_jca_adapter.ManagedTransactionAssistanceFactory"',
          'jndi-name="java:/jboss/jca-generic"',
          'security-application=true'
        ].join ', '
        cmd4 = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-generic:add(#{params})"
        expect(provider).to receive(:execute_with_fail).with(
          'Resource adapter connection-definition',
          cmd4,
          'to create'
        )
      end
      it { expect(subject).to be(:created) }
    end

    describe '#destroy' do
      subject { provider.destroy }
      before :each do
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:remove()"
        expect(provider).to receive(:execute_with_fail).with(
          'Resource adapter',
          cmd,
          'to remove'
        )
      end
      it { expect(subject).to be(:destroyed) }
    end

    describe '#jndiname=' do
      let(:jndi_to_set) { ['java:/jboss/jca-xtra'] }
      subject do
        provider.jndiname = jndi_to_set
      end
      let(:extended_repl) do
        {
          :jndiname => 'java:/jboss/jca-xtra'
        }
      end
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
      before :each do
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:read-resource(recursive=true)"
        expect(provider).to receive(:execute_and_get).with(cmd).and_return({ :result => true })
        cmd = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-generic:remove()"
        expect(provider).to receive(:execute_with_fail).with(
          'Resource adapter connection-definition',
          cmd,
          'to remove'
        )
        params = [
          'background-validation=true',
          'class-name="ch.maxant.generic_jca_adapter.ManagedTransactionAssistanceFactory"',
          'jndi-name="java:/jboss/jca-xtra"',
          'security-application=true'
        ].join ', '
        cmd = "#{clipath}/resource-adapter=genericconnector.rar/connection-definitions=java\\:\\/jboss\\/jca-xtra:add(#{params})"
        expect(provider).to receive(:execute_with_fail).with(
          'Resource adapter connection-definition',
          cmd,
          'to create'
        )
      end
      it { expect(subject).to eq(['java:/jboss/jca-xtra']) }
    end

    describe '#archive' do
      subject { provider.archive }
      let(:loaded_data) do
        { 'archive' => 'genericconnector.rar' }
      end
      it { expect(subject).to eq('genericconnector.rar') }
    end

    describe '#archive=' do
      subject { provider.archive = 'xa-connector.rar' }
      let(:loaded_data) do
        { 'archive' => 'genericconnector.rar' }
      end
      before :each do
        op = 'write-attribute(name="archive", value="xa-connector.rar")'
        cmd = "#{clipath}/resource-adapter=genericconnector.rar:#{op}"
        expect(provider).to receive(:execute_and_get).with(cmd).and_return({ :result => true })
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
          expect(provider).to receive(:execute_and_get).with(cmd).and_return({ :result => true })
          op = 'undefine-attribute(name=security-domain-and-application)'
          cmd = "#{clipath}/resource-adapter=genericconnector.rar/#{el}:#{op}"
          expect(provider).to receive(:execute_with_fail).with(
            'Resource adapter connection definition attribute security-domain-and-application',
            cmd,
            'to remove'
          )
          op = 'undefine-attribute(name=security-domain)'
          cmd = "#{clipath}/resource-adapter=genericconnector.rar/#{el}:#{op}"
          expect(provider).to receive(:execute_with_fail).with(
            'Resource adapter connection definition attribute security-domain',
            cmd,
            'to remove'
          )
        end
        it { expect(subject).to eq('application') }
      end
    end
  end
end
