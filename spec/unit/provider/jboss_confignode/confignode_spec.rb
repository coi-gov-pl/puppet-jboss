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

    describe '#exists? with clean => true' do
      before :each do
          provider.instance_variable_set(:@clean, true)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe '#exists? with clean => false [wrong context]' do
      before :each do
          provider.instance_variable_set(:@clean, false)

      end

      let(:extended_repl) { {
          :path => :undef,
      } }

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end


end
end
