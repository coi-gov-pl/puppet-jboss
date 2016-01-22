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

  describe 'Puppet::Type::Jboss_jdbcdriver::ProviderJbosscli' do

    let(:described_class) do
      Puppet::Type.type(:jboss_jdbcdriver).provider(:jbosscli)
    end
    let(:sample_repl) do
      {
        :name           => 'app-mails',
        :modulename     => 'super-crm',
        :datasourceclassname         => 'datasourceclassname',
        :xadatasourceclassname       => 'xadsname',
        :classname => 'driverclasname',
      }
    end

    let(:extended_repl) do
      {}
    end

    let(:resource) do
      raw = sample_repl.merge(extended_repl)
      raw[:provider] = described_class.name

      Puppet::Type.type(:jboss_jdbcdriver).new(raw)
    end

    let(:provider) do
      resource.provider
    end

    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
    end

    describe '#create' do
      before :each do

      cmdlizedMap = 'driver-class-name="driverclasname",driver-datasource-class-name="datasourceclassname",driver-module-name="super-crm",driver-name="app-mails",driver-xa-datasource-class-name="xadsname"'


      cmd = "/subsystem=datasources/jdbc-driver=app-mails:add(#{cmdlizedMap})"
      compiledcmd = "/profile=full-ha/#{cmd}"
      bringUpName = 'JDBC-Driver'
      expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)

      expect(provider).to receive(:bringUp).with(bringUpName, compiledcmd).and_return(true)
    end

    subject { provider.create }
    it { expect(subject).to eq(true) }
    end

    describe '#destroy' do
      before :each do

        cmd = "/subsystem=datasources/jdbc-driver=#{resource[:name]}:remove"
        compiledcmd = "/profile=full-ha/#{cmd}"
        bringDownName = 'JDBC-Driver'

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)
        expect(provider).to receive(:bringDown).with(bringDownName, compiledcmd).and_return(true)
      end

      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end

    describe 'exists?' do
      before :each do
        cmd = "/subsystem=datasources/jdbc-driver=#{resource[:name]}:read-resource(recursive=true)"
        compiledcmd = "/profile=full-ha/#{cmd}"
        expected_output = {
          :result => true,
        }

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)
        expect(provider).to receive(:executeAndGet).with(compiledcmd).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(true)}
    end

end
end
