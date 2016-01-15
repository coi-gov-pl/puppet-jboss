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
    end

    describe '#create with servergroups nill' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups'
        expect(provider).to receive(:bringUp).with(bringDownName, cmd ).and_return('asd')
      end
      subject { provider.create }
      it { expect(subject).to eq('asd') }
    end

    describe '#create wit servergroups not nill' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --server-groups=crm-servers'

        expect(provider).to receive(:bringUp).with(bringDownName, cmd ).and_return('asd')
      end

      let(:extended_repl) { {
          :servergroups => ['crm-servers'],
        } }
      subject { provider.create }

      it { expect(subject).to eq('asd') }
    end

    describe '#create with redeploy' do
      before :each do
        bringDownName = 'Deployment'
        cmd = 'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups --force'

        expect(provider).to receive(:bringUp).with(bringDownName, cmd ).and_return('asd')
      end
      let(:extended_repl) { {
          :redeploy => true,
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

end
end
