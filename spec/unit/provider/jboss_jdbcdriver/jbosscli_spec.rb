require 'spec_helper_puppet'

context 'mocking default values' do
  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999'
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
        :name                  => 'app-mails',
        :modulename            => 'super-crm',
        :datasourceclassname   => 'datasourceclassname',
        :xadatasourceclassname => 'xadsname',
        :classname             => 'driverclasname'
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
        cmdlized_map = 'driver-class-name="driverclasname",driver-datasource-class-name="datasourceclassname",' \
        'driver-module-name="super-crm",driver-name="app-mails",driver-xa-datasource-class-name="xadsname"'

        cmd = "/subsystem=datasources/jdbc-driver=app-mails:add(#{cmdlized_map})"
        compiledcmd = "/profile=full-ha/#{cmd}"
        bring_up_name = 'JDBC-Driver'
        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)

        expect(provider).to receive(:bringUp).with(bring_up_name, compiledcmd).and_return(true)
      end

      subject { provider.create }
      it { expect(subject).to eq(true) }
    end

    describe '#destroy' do
      before :each do
        cmd = "/subsystem=datasources/jdbc-driver=#{resource[:name]}:remove"
        compiledcmd = "/profile=full-ha/#{cmd}"
        bring_down_name = 'JDBC-Driver'

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)
        expect(provider).to receive(:bringDown).with(bring_down_name, compiledcmd).and_return(true)
      end

      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end

    describe 'exists?' do
      before :each do
        cmd = "/subsystem=datasources/jdbc-driver=#{resource[:name]}:read-resource(recursive=true)"
        compiledcmd = "/profile=full-ha/#{cmd}"
        expected_output = {
          :result => true
        }

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)
        expect(provider).to receive(:executeAndGet).with(compiledcmd).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(true) }
    end

    describe 'exists? when result is flse' do
      before :each do
        cmd = "/subsystem=datasources/jdbc-driver=#{resource[:name]}:read-resource(recursive=true)"
        compiledcmd = "/profile=full-ha/#{cmd}"
        expected_output = {
          :result => false
        }

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)
        expect(provider).to receive(:executeAndGet).with(compiledcmd).and_return(expected_output)
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe 'setattrib' do
      before :each do
        cmd = '/subsystem=datasources/jdbc-driver=app-mails:write-attribute(name=super-name, value=driver-xa-datasource-class-name)'
        compiledcmd = "/profile=full-ha/#{cmd}"

        data = {
          :asd => '1'
        }

        expected_res = {
          :cmd    => compiledcmd,
          :result => res_result,
          :lines  => data
        }
        expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)
        expect(provider).to receive(:executeAndGet).with(compiledcmd).and_return(expected_res)
      end

      subject { provider.setattrib 'super-name', 'driver-xa-datasource-class-name' }
      let(:res_result) { false }
      it { expect { subject }.to raise_error(RuntimeError) }
    end
  end
end
