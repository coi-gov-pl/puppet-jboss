require "spec_helper"

context "mocking default values" do

  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999',
    }
  end

  before :each do
    Puppet_X::Coi::Jboss::Configuration.reset_config(mock_values)
  end

  after :each do
    Puppet_X::Coi::Jboss::Configuration.reset_config
  end

  describe 'Puppet::Type::Confignode::ProviderJbosscli' do

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
            :result => false,
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
            :data => {
              :includeruntime => true,
              :includedefaults => false,
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

    describe '#destroy with exists? => true and status :running => nil' do
      before :each do

        bringDownName = 'Configuration node'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:remove()'

        expect(provider).to receive(:bringDown).with(bringDownName, cmd).and_return(true)
        expect(provider).to receive(:exists?).and_return(true, true)
      end


      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end

    describe "#create with exists? => true" do
      before :each do
        expect(provider).to receive(:exists?).and_return(true)
      end

      subject { provider.create }
      it { expect(subject).to eq(nil) }
    end


    describe "#create with exists? => false" do
      before :each do

        bringUpName = 'Configuration node'
        cmd = '/profile=full/subsystem=messaging/hornetq-server=default:add(security-enabled=false)'

        expect(provider).to receive(:exists?).and_return(false)
        expect(provider).to receive(:bringUp).with(bringUpName, cmd).and_return(true)
      end

      subject { provider.create }
      it { expect(subject).to eq(true) }
    end

    describe '#ensure no specific value' do
      before :each do
        data = {
          :status => 'true',
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
          'status' => 'disabled',
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
          'status' => 'RUNNING',
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
          'status' => 'else',
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
          'enabled' => true,
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
          'enabled' => false,
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

    describe '#ensure :enabled' do
      before :each do

        expect(provider).to receive(:doEnable).and_return(true)
      end

      subject { provider.ensure = :enabled }
      it { expect(subject).to eq(:enabled) }
    end

    describe '#ensure :disabled' do
      before :each do

        expect(provider).to receive(:doDisable).and_return(true)
      end

      subject { provider.ensure = :disabled }
      it { expect(subject).to eq(:disabled) }
    end



end
end
