require 'spec_helper_puppet'

describe 'mocking default values' do
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

  describe 'Puppet::Type::Jboss_confignode::ProviderJbosscli' do
    let(:described_class) do
      Puppet::Type.type(:jboss_confignode).provider(:jbosscli)
    end
    let(:sample_repl) do
      {
        :name       => '/subsystem=messaging/hornetq-server=default',
        :path       => '/subsystem=messaging/hornetq-server=default',
        :ensure     => 'present',
        :properties => {
          'security-enabled' => false,
          'some-other-prop'  => nil
        }
      }
    end

    let(:extended_repl) do
      {}
    end

    let(:resource) do
      raw = sample_repl.merge(extended_repl)
      raw[:provider] = described_class.name

      Puppet::Type.type(:jboss_confignode).new(raw)
    end

    let(:provider) do
      resource.provider
    end

    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
    end

    describe '#exists? with clean => true and result => false' do
      before :each do
        provider.instance_variable_set(:@clean, false)

        cmd =
          '/profile=full/subsystem=messaging/hornetq-server=default:read-resource(include-runtime=true, include-defaults=false)'

        expected_output = {
          :result => false
        }
        expect(provider).to receive(:executeAndGet).with(cmd).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe '#exists? with clean => true and result => true' do
      before :each do
        provider.instance_variable_set(:@clean, false)

        cmd =
          '/profile=full/subsystem=messaging/hornetq-server=default:read-resource(include-runtime=true, include-defaults=false)'

        expected_output = {
          :result => true,
          :data   => {
            :includeruntime  => true,
            :includedefaults => false
          }
        }

        expect(provider).to receive(:executeAndGet).with(cmd).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(true) }
    end

    describe '#exists? with clean => false [wrong context]' do
      before :each do
        provider.instance_variable_set(:@clean, true)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe '#destroy with exists? => false' do
      before :each do
        expect(provider).to receive(:exists?).and_return(false)
      end

      subject { provider.destroy }
      it { expect(subject).to eq(nil) }
    end

    describe '#destroy with status == :running and later on :ensure' do
      before :each do
        bring_down_name = 'Configuration node STOP'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:stop(blocking=true)'

        bring_down_name_destroy = 'Configuration node'
        cmd_destroy = '/profile=full/subsystem=messaging/hornetq-server=default:remove()'

        expect(provider).to receive(:exists?).and_return(true)
        expect(provider).to receive(:status).and_return(:running)
        expect(provider).to receive(:status).and_return(:ensure)
        expect(provider).to receive(:bringDown).with(bring_down_name, cmd).and_return(true)
        expect(provider).to receive(:bringDown).with(bring_down_name_destroy, cmd_destroy).and_return(true)
      end

      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end

    describe '#destroy with exists? => true and status :running => nil' do
      before :each do
        bring_down_name = 'Configuration node'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:remove()'

        expect(provider).to receive(:bringDown).with(bring_down_name, cmd).and_return(true)
        expect(provider).to receive(:exists?).and_return(true, true)
      end

      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end

    describe '#create with exists? => true' do
      before :each do
        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.create }
      it { expect(subject).to eq(nil) }
    end

    describe '#create with exists? => false' do
      before :each do
        bring_up_name = 'Configuration node'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:add(security-enabled=false)'

        expect(provider).to receive(:exists?).and_return(false)
        expect(provider).to receive(:bringUp).with(bring_up_name, cmd).and_return(true)
      end

      subject { provider.create }
      it { expect(subject).to eq(true) }
    end

    describe '#ensure no specific value' do
      before :each do
        data = {
          :status => 'true'
        }

        provider.instance_variable_set(:@data, data)

        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.ensure }
      it { expect(subject).to eq(:present) }
    end

    describe '#ensure with status => disabled' do
      before :each do
        data = {
          'status' => 'disabled'
        }

        provider.instance_variable_set(:@data, data)

        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.ensure }
      it { expect(subject).to eq(:disabled) }
    end

    describe '#ensure with status => RUNNING' do
      before :each do
        data = {
          'status' => 'RUNNING'
        }

        provider.instance_variable_set(:@data, data)

        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.ensure }
      it { expect(subject).to eq(:running) }
    end

    describe '#ensure with status => else' do
      before :each do
        data = {
          'status' => 'else'
        }

        provider.instance_variable_set(:@data, data)

        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.ensure }
      it { expect(subject).to eq(:stopped) }
    end

    describe '#ensure with enabled => true' do
      before :each do
        data = {
          'enabled' => true
        }

        provider.instance_variable_set(:@data, data)

        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.ensure }
      it { expect(subject).to eq(:enabled) }
    end

    describe '#ensure with enabled => else' do
      before :each do
        data = {
          'enabled' => false
        }

        provider.instance_variable_set(:@data, data)

        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.ensure }
      it { expect(subject).to eq(:disabled) }
    end

    describe '#ensure :asd' do
      before :each do
      end

      subject { provider.ensure = 'asd' }
      it { expect(subject).to eq('asd') }
    end

    describe '#ensure :present' do
      before :each do
      end

      subject { provider.ensure = 'asd' }
      it { expect(subject).to eq('asd') }
    end

    describe '#ensure :present' do
      before :each do
        expect(provider).to receive(:create).and_return(true)
      end

      subject { provider.ensure = :present }
      it { expect(subject).to eq(:present) }
    end

    describe '#ensure :absent' do
      before :each do
        expect(provider).to receive(:destroy).and_return(true)
      end

      subject { provider.ensure = :absent }
      it { expect(subject).to eq(:absent) }
    end

    describe '#ensure :running' do
      before :each do
        expect(provider).to receive(:doStart).and_return(true)
      end

      subject { provider.ensure = :running }
      it { expect(subject).to eq(:running) }
    end

    describe '#ensure :stopped' do
      before :each do
        expect(provider).to receive(:doStop).and_return(true)
      end

      subject { provider.ensure = :stopped }
      it { expect(subject).to eq(:stopped) }
    end

    describe '#ensure :enabled with status :ensure' do
      before :each do
        bring_up_name = 'Configuration node ENABLE'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:enable()'

        expect(provider).to receive(:status).and_return(:ensure)
        expect(provider).to receive(:bringUp).with(bring_up_name, cmd).and_return(true)
      end

      subject { provider.ensure = :enabled }
      it { expect(subject).to eq(:enabled) }
    end

    describe '#ensure :enabled with status :absent' do
      before :each do
        bring_up_name = 'Configuration node ENABLE'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:enable()'

        expect(provider).to receive(:status).and_return(:ensure)
        expect(provider).to receive(:bringUp).with(bring_up_name, cmd).and_return(true)
      end

      subject { provider.ensure = :enabled }
      it { expect(subject).to eq(:enabled) }
    end

    describe '#ensure= value with value => :running' do
      before :each do
        bring_up_name = 'Configuration node START'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:start(blocking=true)'

        expect(provider).to receive(:status).and_return(:absent)
        expect(provider).to receive(:create).and_return(true)
        expect(provider).to receive(:bringUp).with(bring_up_name, cmd).and_return(true)
      end

      subject { provider.ensure = :running }
      it { expect(subject).to eq(:running) }
    end

    describe '#ensure :disabled' do
      before :each do
        expect(provider).to receive(:doDisable).and_return(true)
      end

      subject { provider.ensure = :disabled }
      it { expect(subject).to eq(:disabled) }
    end

    describe '#ensure= value with value => :stopped' do
      before :each do
        bring_up_name = 'Configuration node STOP'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:stop(blocking=true)'

        expect(provider).to receive(:status).and_return(:absent)
        expect(provider).to receive(:create).and_return(true)
        expect(provider).to receive(:bringDown).with(bring_up_name, cmd).and_return(true)
      end

      subject { provider.ensure = :stopped }
      it { expect(subject).to eq(:stopped) }
    end

    describe '#ensure= value with value => :enabled' do
      before :each do
        bring_up_name = 'Configuration node ENABLE'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:enable()'

        expect(provider).to receive(:status).and_return(:absent)
        expect(provider).to receive(:create).and_return(true)
        expect(provider).to receive(:bringUp).with(bring_up_name, cmd).and_return(true)
      end

      subject { provider.ensure = :enabled }
      it { expect(subject).to eq(:enabled) }
    end

    describe '#ensure= value with value => :disabled' do
      before :each do
        bring_up_name = 'Configuration node DISABLE'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:disable()'

        expect(provider).to receive(:status).and_return(:absent)
        expect(provider).to receive(:create).and_return(true)
        expect(provider).to receive(:bringDown).with(bring_up_name, cmd).and_return(true)
      end

      subject { provider.ensure = :disabled }
      it { expect(subject).to eq(:disabled) }
    end

    describe '#properties and @data => nil' do
      before :each do
        provider.instance_variable_set(:@data, nil)
      end

      subject { provider.properties }
      it { expect(subject).to eq({}) }
    end

    describe '#properties and @data => asd ' do
      before :each do
        property_hash = {
          :properties => { 'security-enabled' => false }
        }
        provider.instance_variable_set(:@data, 'asd')
        provider.instance_variable_set(:@property_hash, property_hash)
      end

      subject { provider.properties }
      it { expect(subject).to eq('security-enabled' => false) }
    end

    describe '#properties and @data => asd and value is keyword' do
      before :each do
        property_hash = {
          :properties => { 'security-enabled' => :false }
        }
        provider.instance_variable_set(:@data, 'asd')
        provider.instance_variable_set(:@property_hash, property_hash)
      end

      subject { provider.properties }
      it { expect(subject).to eq('security-enabled' => 'false') }
    end

    describe '#properties' do
      before :each do
        data = { :aaa => :bbb }
        provider.instance_variable_set(:@data, data)

        bring_up_name = 'Configuration node property'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:write-attribute(name=security-enabled, value=:false)'

        expect(provider).to receive(:bringUp).with(bring_up_name, cmd).and_return(true)
      end

      props = {
        'security-enabled' => :false
      }
      subject { provider.properties = props }
      it { expect(subject).to eq('security-enabled' => :false) }
    end
  end
end
