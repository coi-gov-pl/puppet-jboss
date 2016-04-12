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

  describe 'Puppet::Type::Jboss_deploy::ProviderJbosscli' do

    let(:described_class) do
      Puppet::Type.type(:jboss_deploy).provider(:jbosscli)
    end
    let(:sample_repl) do
      {
        :name => 'super-crm-1.1.0',
        :source => '/usr/src/super-crm-1.1.0.war',
      }
    end

    let(:mocked_process_status) do
      process_status = double('Mocked process status', :exitstatus => 0, :success? => true)
    end

    let(:mocked_system_executor) do
      mck_system_executor = Puppet_X::Coi::Jboss::Internal::JbossSystemExec.new
      allow(mck_system_executor).to receive(:run_command)
      allow(mck_system_executor).to receive(:child_status).and_return(mocked_process_status)
    end

    let(:extended_repl) do
      {}
    end

    let(:resource) do
      raw = sample_repl.merge(extended_repl)
      raw[:provider] = described_class.name

      Puppet::Type.type(:jboss_deploy).new(raw)
    end

    let(:provider) do
      resource.provider
    end

    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
      provider.runner = mocked_system_executor
    end

    describe '#create with servergroups nill' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups --force'

        expect(provider).to receive(:bringUp).with(bringDownName, cmd ).and_return('asd')
      end
      subject { provider.create }
      it { expect(subject).to eq('asd') }
    end

    describe '#create wit servergroups not nill' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --server-groups=crm-servers --force'

        expect(provider).to receive(:bringUp).with(bringDownName, cmd).and_return('asd')
      end

      let(:extended_repl) { {
          :servergroups => ['crm-servers'],
        } }
      subject { provider.create }

      it { expect(subject).to eq('asd') }
    end

    describe '#create with redeploy_on_refresh' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups --force'

        expect(provider).to receive(:bringUp).with(bringDownName, cmd).and_return('asd')
      end
      let(:extended_repl) { {
          :redeploy_on_refresh => true,
        } }
      subject { provider.create }
      it { expect(subject).to eq('asd') }
    end

    describe '#destroy with runasdomain => true' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'undeploy super-crm-1.1.0 --all-relevant-server-groups'

        expect(provider).to receive(:bringDown).with(bringDownName, cmd).and_return('asd')
      end
      let(:extended_repl) { {
          :runasdomain => true
        } }

      subject { provider.destroy }
      it { expect(subject).to eq('asd') }
    end

    describe '#destroy with servergroups nill' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'undeploy super-crm-1.1.0 --all-relevant-server-groups'
        expect(provider).to receive(:bringDown).with(bringDownName, cmd).and_return('asd')
      end

      let(:extended_repl) { {
          :runasdomain => true
        } }

      subject { provider.destroy }
      it { expect(subject).to eq('asd') }
    end

    describe '#destroy with servergroups not nill' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'undeploy super-crm-1.1.0 --server-groups=crm-servers'
        expect(provider).to receive(:bringDown).with(bringDownName, cmd).and_return('asd')
      end

      let(:extended_repl) { {
          :runasdomain => true,
          :servergroups => ['crm-servers'],
        } }

      subject { provider.destroy }
      it { expect(subject).to eq('asd') }
    end

    describe '#exist? with tests for name_exists?' do
      before :each do
        allow(provider).to receive(:is_exact_deployment?).and_return(:expected_mocked_output)
      end
      describe '#name_exists? and outcome => failed' do
        before :each do
          cmd = "/deployment=super-crm-1.1.0:read-resource()"
          expected_output = { :outcome => 'failed'}

          expect(provider).to receive(:executeWithoutRetry).with(cmd).and_return(expected_output)
        end

        subject { provider.exists? }
        it { expect(subject).to eq(false) }
      end

      describe '#exists? and :outcome => success and :name => asd' do
        before :each do
          cmd = "/deployment=super-crm-1.1.0:read-resource()"
          expected_output = {
            :outcome => 'success',
            :name    => 'asd',
            }

          expect(provider).to receive(:executeWithoutRetry).with(cmd).and_return(expected_output)
        end

        subject { provider.exists? }
        it { expect(subject).to eq(:expected_mocked_output) }
      end

      describe '#name_exists? and :outcome => success and :name => nil' do
        before :each do
          cmd = "/deployment=super-crm-1.1.0:read-resource()"
          expected_output = {
            :outcome => 'success',
            }

          expect(provider).to receive(:executeWithoutRetry).with(cmd).and_return(expected_output)
        end

        subject { provider.exists? }
        it { expect(subject).to eq(false) }
      end
    end

    describe '#servergroups with runasdomain => false' do
      before :each do
      end

      let(:extended_repl) { {
          :runasdomain => false,
          :servergroups => ['crm-servers'],
        } }

      subject { provider.servergroups }
      it { expect(subject).to eq(['crm-servers']) }
    end

    describe '#servergroups with runasdomain => true and :result => false' do
      before :each do

        expected_output = {
          :result => false,
          :name    => 'asd',
          }

        cmd = "deployment-info --name=#{resource[:name]}"

        expect(provider).to receive(:execute).with(cmd).and_return(expected_output)
      end

      let(:extended_repl) { {
          :runasdomain => true,
        } }

      subject { provider.servergroups }
      it { expect(subject).to eq([]) }
    end

    describe '#servergroups with runasdomain => true and :result => true and lines => added  and :servergroups => not nil' do
      before :each do

        content =  <<-eos
        NAME RUNTIME-NAME
        super-crm  super-crm

        SERVER-GROUP STATE
        app-group    added
        eos

        lines = content.split("\n")

        expected_output = {
          :result => true,
          :name   => 'asd',
          :lines => lines,
          }

        cmd = "deployment-info --name=#{resource[:name]}"

        expect(provider).to receive(:execute).with(cmd).and_return(expected_output)
      end

      let(:extended_repl) { {
          :runasdomain => true,
          :servergroups => 'crm-servers',
        } }

      subject { provider.servergroups }
      it { expect(subject).to eq(['app-group']) }
    end

    describe '#servergroups with runasdomain => true and :result => true and lines => added  and :servergroups => nil' do
      before :each do

        content =  <<-eos
        NAME RUNTIME-NAME
        super-crm  super-crm

        SERVER-GROUP STATE
        app-group    added
        eos

        lines = content.split("\n")

        expected_output = {
          :result => true,
          :name   => 'asd',
          :lines => lines,
          }

        cmd = "deployment-info --name=#{resource[:name]}"

        expect(provider).to receive(:execute).with(cmd).and_return(expected_output)
      end

      let(:extended_repl) { {
          :runasdomain => true,
        } }

      subject { provider.servergroups }
      it { expect(subject).to eq(nil) }
    end

    describe '#servergroups with value' do
      before :each do
        cmd = "deploy --name=#{resource[:name]} --server-groups=super-crm-1"

        expect(provider).to receive(:servergroups).and_return(['super-crm'])
        expect(provider).to receive(:bringUp).with('Deployment', cmd).and_return('asd')
      end

      subject { provider.servergroups = ['super-crm', 'super-crm-1'] }
      it { expect(subject).to eq(["super-crm", "super-crm-1"]) }
    end

    describe '#redeploy_on_refresh' do

      context 'with default value' do
        before :each do

          bringDownName = 'Deployment'
          cmd = 'undeploy super-crm-1.1.0 --all-relevant-server-groups'

          bringUpName = 'Deployment'
          cmd2 = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups --force'

          expect(provider).to receive(:bringDown).with(bringDownName, cmd).and_return('asd')
          expect(provider).to receive(:bringUp).with(bringDownName, cmd2).and_return('asd')

        end

        let(:extended_repl) { {
            :redeploy_on_refresh => true,
          } }

        subject { provider.redeploy_on_refresh }
        it { expect(subject).to eq('asd') }
      end

      context 'with value set to false' do
        before :each do

          bringUpName = 'Deployment'
          cmd = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups'

          expect(provider).to receive(:bringUp).with(bringUpName, cmd).and_return('asd')
        end
        let(:extended_repl) { {
            :redeploy_on_refresh => false,
          } }

        subject { provider.redeploy_on_refresh }
        it { expect(subject).to eq('asd') }
      end
    end
end
end
