require 'spec_helper_puppet'

describe 'Puppet::Type::JBoss_jmsqueue::ProviderJbosscli' do
  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999',
      :home       => '/usr/local/jboss-eap-6.4.0.GA'
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

  let(:executor) { Testing::Mock::ExecutionStateWrapper.new }

  let(:provider) do
    provider = resource.provider
    provider.executor(executor)
    provider
  end

  describe '#create wth runasdomain? => true' do
    let(:extended_repl) do
      { :runasdomain => true }
    end
    before :each do
      compiled_cmd_subsystem = '/profile=full-ha/subsystem=messaging'
      executor.register_failing_command(
        '/extension=org.jboss.as.messaging:read-resource()'
      )
      executor.register_command(
        '/extension=org.jboss.as.messaging:add()'
      )
      executor.register_failing_command(
        "#{compiled_cmd_subsystem}:read-resource()"
      )
      executor.register_command(
        "#{compiled_cmd_subsystem}:add()"
      )
      hornet_cmd = 'hornetq-server=default'
      compiled_hornet_cmd = "#{compiled_cmd_subsystem}/#{hornet_cmd}"
      exec_hornet_cmd = "#{compiled_hornet_cmd}:read-resource()"
      hornet_bring_up_cmd = "#{compiled_hornet_cmd}:add()"
      executor.register_failing_command(exec_hornet_cmd)
      executor.register_command(hornet_bring_up_cmd)

      final_cmd = 'jms-queue --profile=full-ha add --queue-address=app-mails ' \
        '--entries=["queue/app-mails", "java:jboss/exported/jms/queue/app-mails"] --durable=true'
      executor.register_command(final_cmd)
    end

    subject { provider.create }
    it { expect(subject.success?).to eq(true) }
  end

  describe '#destroy' do
    let(:extended_repl) do
      { :runasdomain => true }
    end
    before :each do
      cmd = "jms-queue --profile=#{resource[:profile]} remove --queue-address=#{resource[:name]}"
      executor.register_command(cmd)
    end

    subject { provider.destroy }
    it { expect(subject.success?).to eq(true) }
  end

  describe '#exists?' do
    describe 'with result => true' do
      before :each do
        cmd = "/subsystem=messaging/hornetq-server=default/jms-queue=#{resource[:name]}:read-resource()"
        compiled_cmd = "/profile=full-ha#{cmd}"
        executor.register_command(
          compiled_cmd,
          {
            'outcome' => 'success',
            'result'  => 'asd'
          }
        )
      end

      subject { provider.exists? }
      it { expect(subject).to eq(true) }
    end

    describe 'with result => false' do
      before :each do
        cmd = "/subsystem=messaging/hornetq-server=default/jms-queue=#{resource[:name]}:read-resource()"
        compiled_cmd = "/profile=full-ha#{cmd}"
        expected_output = {
          'outcome' => 'failure',
          'result'  => 'asd'
        }
        executor.register_command(
          compiled_cmd, expected_output
        )
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end
  end

  describe 'managed properties' do
    before :each do
      executor.register_command(
        '/profile=full-ha/subsystem=messaging/hornetq-server=default/jms-queue=app-mails:read-resource()',
        {
          'outcome' => 'success',
          'result'  => data
        }
      )
      provider.exists?
    end

    describe '#durable' do
      let(:data) do
        { 'durable' => durable }
      end
      describe 'getting value' do
        let(:durable) { true }
        subject { provider.durable }
        it { expect(subject).to eq('true') }
      end

      describe 'setting with true' do
        let(:durable) { false }
        before :each do
          executor.register_command(
            '/profile=full-ha/subsystem=messaging/hornetq-server=default/jms-queue=app-mails' \
            ':write-attribute(name="durable", value=true)'
          )
        end
        subject { provider.durable = true }
        it { expect(subject).to eq(true) }
      end
    end

    describe '#entries' do
      let(:data) do
        { 'entries' => 'Lorem ipsum' }
      end
      describe 'getting value' do
        subject { provider.entries }
        it { expect(subject).to eq('Lorem ipsum') }
      end

      describe 'setting with "true", "false"' do
        before :each do
          entries = '["true", "false"]'
          executor.register_command(
            '/profile=full-ha/subsystem=messaging/hornetq-server=default/jms-queue=app-mails' \
            ":write-attribute(name=\"entries\", value=#{entries})"
          )
        end

        subject { provider.entries = %w[true false] }
        it { expect(subject).to eq(%w[true false]) }
      end
    end
  end
end
