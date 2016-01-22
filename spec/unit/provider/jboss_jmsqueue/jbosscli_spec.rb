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
      Puppet::Type.type(:jboss_jmsqueue).provider(:jbosscli)
    end
    let(:sample_repl) do
      {
        :name       => 'app-mails',
        :durable    => true,
        :ensure     => 'present',
        :entries => [
          'queue/app-mails',
          'java:jboss/exported/jms/queue/app-mails',
        ],
        :profile   => 'full-ha'
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
      resource.provider
    end

    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
    end

    describe '#create wth runasdomain? => true' do
      before :each do


        bringUpName = 'Extension - messaging'
        bringUpNameSubsytem = 'Subsystem - messaging'
        profile = resource[:profile]
        cmd = "/extension=org.jboss.as.messaging:add()"
        cmd2 =
        execCMD = '/extension=org.jboss.as.messaging:read-resource()'
        execCMD_expected_output = {
          :result => false,
        }
        execCMD2 = '/extension=org.jboss.as.messaging:add()'

        # line 4
        expect(provider).to receive(:runasdomain?).and_return(true)

        # line 17
        expect(provider).to receive(:execute).with(execCMD).and_return(execCMD_expected_output)

        # line 18
        expect(provider).to receive(:bringUp).with(bringUpName, execCMD2).and_return(true)

        # line 20
        cmdCompile = '/subsystem=messaging'
        compiledCMDSubsystem = '/profile/full-ha/subsystem=messaging'
        expect(provider).to receive(:compilecmd).with(cmdCompile).and_return(compiledCMDSubsystem)

        # line 21
        execCMDSubsystem = "#{compiledCMDSubsystem}:read-resource()"
        expect(provider).to receive(:execute).with(execCMDSubsystem).and_return(execCMD_expected_output)

        # line 22
        cmdSubsystem = "#{compiledCMDSubsystem}:add()"
        expect(provider).to receive(:bringUp).with(bringUpNameSubsytem, cmdSubsystem).and_return(true)

        # line 24
        hornetCMD = '/subsystem=messaging/hornetq-server=default'
        compiledHornetCMD = "/profile/full-ha/#{hornetCMD}"
        execHornetCMD = "#{compiledHornetCMD}:read-resource()"
        hornetBringUpName = 'Default HornetQ'
        horneBringUpCMD = "#{compiledHornetCMD}:add()"

        expect(provider).to receive(:compilecmd).with(hornetCMD).and_return(compiledHornetCMD)
        expect(provider).to receive(:execute).with(execHornetCMD).and_return(execCMD_expected_output)
        expect(provider).to receive(:bringUp).with(hornetBringUpName, horneBringUpCMD).and_return(true)

        # line 28
        finalCMD = "jms-queue --profile=full-ha add --queue-address=#{resource[:name]} --entries=#{resource[:entries]} --durable=\"#{resource[:durable].to_s}\""
        finalBringUpName = 'JMS Queue'
        expect(provider).to receive(:bringUp).with(finalBringUpName, finalCMD).and_return(true)

      end

      subject { provider.create }
      it {expect(subject).to eq(true)}
    end

    describe '#destroy' do
      before :each do
        expect(provider).to receive(:runasdomain?).and_return(true)
        cmd = "jms-queue --profile=#{resource[:profile]} remove --queue-address=#{resource[:name]}"
        bringDownName = 'JMS Queue'
        expect(provider).to receive(:bringDown).with(bringDownName, cmd).and_return(true)
      end

      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end

    describe '#exists? with result => true' do
      before :each do
        $data = nil
        cmd = "/subsystem=messaging/hornetq-server=default/jms-queue=#{resource[:name]}:read-resource()"
        compiledCMD = "/profile=full-ha#{cmd}"

        expected_output = {
          :result => true,
          :data   => 'asd',
        }

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledCMD)
        expect(provider).to receive(:executeAndGet).with(compiledCMD).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(true) }
    end

    describe '#exists? with result => false' do
      before :each do
        $data = nil
        cmd = "/subsystem=messaging/hornetq-server=default/jms-queue=#{resource[:name]}:read-resource()"
        compiledCMD = "/profile=full-ha#{cmd}"

        expected_output = {
          :result => false,
          :data   => 'asd',
        }

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledCMD)
        expect(provider).to receive(:executeAndGet).with(compiledCMD).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe '#durable' do
      before :each do
        $data = {
          'durable' => 'true',
        }
      end
      subject { provider.durable }
      it { expect(subject).to eq("true") }
    end

    describe '#durable = true' do
      before :each do
        expect(provider).to receive(:setattr).with('durable', "\"true\"").and_return(true)
      end
      subject { provider.durable = "true" }
      it { expect(subject).to eq("true") }
    end

    describe '#entries' do
      before :each do
        $data = {
          'entries' => 'asd',
        }
      end
      subject { provider.entries }
      it { expect(subject).to eq('asd') }
    end

    describe "#entries with true" do
      before :each do
        entries = "[\"true\"]"
        expect(provider).to receive(:setattr).with('entries', entries).and_return("true")
      end

      subject { provider.entries= ['true'] }
      it { expect(subject).to eq (["true"]) }
    end
end
end
