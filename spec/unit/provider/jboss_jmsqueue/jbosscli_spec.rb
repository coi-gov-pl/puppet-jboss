require 'spec_helper_puppet'

describe 'mocking default values' do
  module DataSetter
    def data=(data)
      @data = data
    end
  end

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

  describe 'Puppet::Type::JBoss_jmsqueue::ProviderJbosscli' do
    let(:described_class) do
      Puppet::Type.type(:jboss_jmsqueue).provider(:jbosscli)
    end
    let(:sample_repl) do
      {
        :name    => 'app-mails',
        :durable => true,
        :ensure  => 'present',
        :profile => 'full-ha',
        :entries => [
          'queue/app-mails',
          'java:jboss/exported/jms/queue/app-mails'
        ]
      }
    end

    let(:extended_repl) do
      {}
    end

    let(:resource) do
      raw = sample_repl.merge(extended_repl)
      raw[:provider] = described_class.name

      Puppet::Type.type(:jboss_jmsqueue).new(raw)
    end

    let(:provider) do
      resource.provider.extend DataSetter
      resource.provider
    end

    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
    end

    describe '#create wth runasdomain? => true' do
      before :each do
        bring_up_name = 'Extension - messaging'
        bring_up_name_subsytem = 'Subsystem - messaging'
        exec_cmd = '/extension=org.jboss.as.messaging:read-resource()'
        exec_cmd_expected_output = {
          :result => false
        }
        exec_cmd2 = '/extension=org.jboss.as.messaging:add()'

        # line 4
        expect(provider).to receive(:is_runasdomain).and_return(true)

        # line 17
        expect(provider).to receive(:execute).with(exec_cmd).and_return(exec_cmd_expected_output)

        # line 18
        expect(provider).to receive(:bringUp).with(bring_up_name, exec_cmd2).and_return(true)

        # line 20
        cmd_compile = '/subsystem=messaging'
        compiled_cmd_subsystem = '/profile=full-ha/subsystem=messaging'
        expect(provider).to receive(:compilecmd).with(cmd_compile).and_return(compiled_cmd_subsystem)

        # line 21
        exec_cmd_subsystem = "#{compiled_cmd_subsystem}:read-resource()"
        expect(provider).to receive(:execute).with(exec_cmd_subsystem).and_return(exec_cmd_expected_output)

        # line 22
        cmd_subsystem = "#{compiled_cmd_subsystem}:add()"
        expect(provider).to receive(:bringUp).with(bring_up_name_subsytem, cmd_subsystem).and_return(true)

        # line 24
        hornet_cmd = '/subsystem=messaging/hornetq-server=default'
        compiled_hornet_cmd = "/profile=full-ha/#{hornet_cmd}"
        exec_hornet_cmd = "#{compiled_hornet_cmd}:read-resource()"
        hornet_bring_up_name = 'Default HornetQ'
        hornet_bring_up_cmd = "#{compiled_hornet_cmd}:add()"

        expect(provider).to receive(:compilecmd).with(hornet_cmd).and_return(compiled_hornet_cmd)
        expect(provider).to receive(:execute).with(exec_hornet_cmd).and_return(exec_cmd_expected_output)
        expect(provider).to receive(:bringUp).with(hornet_bring_up_name, hornet_bring_up_cmd).and_return(true)

        # line 28
        final_cmd = 'jms-queue --profile=full-ha add --queue-address=app-mails ' \
          '--entries=["queue/app-mails", "java:jboss/exported/jms/queue/app-mails"] --durable=true'
        final_bring_up_name = 'JMS Queue'
        expect(provider).to receive(:bringUp).with(final_bring_up_name, final_cmd).and_return(true)
      end

      subject { provider.create }
      it { expect(subject).to eq(true) }
    end

    describe '#destroy' do
      before :each do
        expect(provider).to receive(:is_runasdomain).and_return(true)
        cmd = "jms-queue --profile=#{resource[:profile]} remove --queue-address=#{resource[:name]}"
        bring_down_name = 'JMS Queue'
        expect(provider).to receive(:bringDown).with(bring_down_name, cmd).and_return(true)
      end

      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end

    describe '#exists? with result => true' do
      before :each do
        cmd = "/subsystem=messaging/hornetq-server=default/jms-queue=#{resource[:name]}:read-resource()"
        compiled_cmd = "/profile=full-ha#{cmd}"

        expected_output = {
          :result => true,
          :data   => 'asd'
        }

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiled_cmd)
        expect(provider).to receive(:executeAndGet).with(compiled_cmd).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(true) }
    end

    describe '#exists? with result => false' do
      before :each do
        cmd = "/subsystem=messaging/hornetq-server=default/jms-queue=#{resource[:name]}:read-resource()"
        compiled_cmd = "/profile=full-ha#{cmd}"

        expected_output = {
          :result => false,
          :data   => 'asd'
        }

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiled_cmd)
        expect(provider).to receive(:executeAndGet).with(compiled_cmd).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe '#durable' do
      before :each do
        provider.data = { 'durable' => 'true' }
      end
      subject { provider.durable }
      it { expect(subject).to eq('true') }
    end

    describe '#durable = true' do
      before :each do
        expect(provider).to receive(:setattr).with('durable', '"true"').and_return(true)
      end
      subject { provider.durable = 'true' }
      it { expect(subject).to eq('true') }
    end

    describe '#entries' do
      before :each do
        provider.data = { 'entries' => 'asd' }
      end
      subject { provider.entries }
      it { expect(subject).to eq('asd') }
    end

    describe '#entries with true' do
      before :each do
        entries = '["true", "false"]'
        expect(provider).to receive(:setattr).with('entries', entries).and_return('true')
      end

      subject { provider.entries = %w[true false] }
      it { expect(subject).to eq(%w[true false]) }
    end
  end
end
