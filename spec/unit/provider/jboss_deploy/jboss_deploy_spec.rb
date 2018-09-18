require 'spec_helper_puppet'

describe 'Puppet::Type::Jboss_deploy::ProviderJbosscli' do
  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999',
      :home       => '/usr/share/jboss-8.0'
    }
  end

  before :each do
    PuppetX::Coi::Jboss::Configuration.reset_config(mock_values)
    expect(Puppet).not_to receive(:err)
  end

  after :each do
    PuppetX::Coi::Jboss::Configuration.reset_config
  end

  let(:described_class) do
    Puppet::Type.type(:jboss_deploy).provider(:jbosscli)
  end
  let(:sample_repl) do
    {
      :name   => 'super-crm-1.1.0',
      :source => '/usr/src/super-crm-1.1.0.war'
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

  let(:executor) { Testing::Mock::ExecutionStateWrapper.new }

  let(:provider) do
    provider = resource.provider
    provider.executor(executor)
    provider
  end

  after(:each) { executor.verify_commands_executed }

  describe '#create' do
    before :each do
      executor.register_command(deploy_command)
    end

    describe 'with servergroups nil' do
      let(:deploy_command) do
        'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups --force'
      end
      subject { provider.create }
      it { expect(subject).to eq('super-crm-1.1.0') }
    end

    describe 'with servergroups not nil' do
      let(:deploy_command) do
        'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --server-groups=crm-servers --force'
      end
      let(:extended_repl) do
        { :servergroups => ['crm-servers'] }
      end
      subject { provider.create }
      it { expect(subject).to eq('super-crm-1.1.0') }
    end

    describe 'with redeploy_on_refresh' do
      let(:deploy_command) do
        'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups --force'
      end
      let(:extended_repl) do
        { :redeploy_on_refresh => true }
      end
      subject { provider.create }
      it { expect(subject).to eq('super-crm-1.1.0') }
    end
  end

  describe '#destroy' do
    before :each do
      executor.register_command(undeploy_command)
    end
    describe 'with runasdomain => true' do
      let(:undeploy_command) do
        'undeploy super-crm-1.1.0 --all-relevant-server-groups'
      end
      let(:extended_repl) do
        { :runasdomain => true }
      end

      subject { provider.destroy }
      it { expect(subject).to eq('super-crm-1.1.0') }
    end

    describe 'with servergroups nil' do
      let(:undeploy_command) do
        'undeploy super-crm-1.1.0 --all-relevant-server-groups'
      end
      let(:extended_repl) do
        { :runasdomain => true }
      end

      subject { provider.destroy }
      it { expect(subject).to eq('super-crm-1.1.0') }
    end

    describe 'with servergroups not nil' do
      let(:undeploy_command) do
        'undeploy super-crm-1.1.0 --server-groups=crm-servers'
      end
      let(:extended_repl) do
        { :runasdomain => true, :servergroups => ['crm-servers'] }
      end

      subject { provider.destroy }
      it { expect(subject).to eq('super-crm-1.1.0') }
    end
  end

  describe '#exist?' do
    describe '#name_exists? and outcome => failed' do
      before :each do
        executor.register_command(
          '/deployment=super-crm-1.1.0:read-resource()',
          'not important',
          2
        )
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe 'outcome => success and name => super-crm-1.1.0' do
      let(:artifact_hash) { '69D29C4101F8A4EF3EC6B9231BECE62D877AB050' }
      let(:digest) { double(:file => nil, :hexdigest => artifact_hash) }
      before :each do
        provider.digest = proc { digest }
        executor.register_command(
          '/deployment=super-crm-1.1.0:read-resource()',
          {
            'outcome' => 'success',
            'result'  => {
              'content'           => [{ 'hash' => [
                0x69, 0xd2, 0x9c, 0x41, 0x01, 0xf8, 0xa4, 0xef,
                0x3e, 0xc6, 0xb9, 0x23, 0x1b, 0xec, 0xe6, 0x2d,
                0x87, 0x7a, 0xb0, 0x50
              ] }],
              'enabled'           => true,
              'enabled-time'      => 1_537_389_973_498,
              'enabled-timestamp' => '2018-09-19 20:46:13,498 UTC',
              'name'              => 'servlet3-webapp-2.22.2.war',
              'owner'             => nil,
              'persistent'        => true,
              'runtime-name'      => 'servlet3-webapp-2.22.2.war',
              'subdeployment'     => nil,
              'subsystem'         => {
                'undertow' => nil,
                'jaxrs'    => nil
              }
            }
          }
        )
      end

      subject { provider.exists? }
      it { expect(subject).to eq(true) }
    end

    describe '#name_exists? and :outcome => success and :name => nil' do
      before :each do
        executor.register_command(
          '/deployment=super-crm-1.1.0:read-resource()',
          {
            'outcome' => 'success',
            'result'  => {}
          }
        )
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end
  end

  describe '#servergroups' do
    describe 'with runasdomain => false' do
      let(:extended_repl) do
        { :runasdomain => false, :servergroups => ['crm-servers'] }
      end
      subject { provider.servergroups }
      it { expect(subject).to eq(['crm-servers']) }
    end

    describe 'with runasdomain => true' do
      describe 'and :result => false' do
        before :each do
          executor.register_command(
            'deployment-info --name=super-crm-1.1.0',
            {
              'outcome' => 'success',
              'result'  => ''
            }
          )
        end
        let(:extended_repl) do
          { :runasdomain => true }
        end
        subject { provider.servergroups }
        it { expect(subject).to eq([]) }
      end

      describe 'and proper result with added to one servergroup' do
        before :each do
          executor.register_command(
            "deployment-info --name=#{resource[:name]}",
            <<-eos
            NAME RUNTIME-NAME
            super-crm  super-crm

            SERVER-GROUP STATE
            app-group    added
            other        not added
            eos
          )
        end

        let(:extended_repl) do
          { :runasdomain => true }
        end

        subject { provider.servergroups }
        it { expect(subject).to eq(['app-group']) }
      end

      describe 'and :result => true and lines => added  and :servergroups => nil' do
        before :each do
          executor.register_command(
            "deployment-info --name=#{resource[:name]}",
            <<-eos
            NAME RUNTIME-NAME
            super-crm  super-crm

            SERVER-GROUP STATE
            app-group    not added
            eos
          )
        end

        let(:extended_repl) do
          { :runasdomain => true }
        end

        subject { provider.servergroups }
        it { expect(subject).to eq([]) }
      end
    end

    describe 'with value' do
      before :each do
        executor.register_command(
          "deployment-info --name=#{resource[:name]}",
          <<-eos
          NAME RUNTIME-NAME
          super-crm  super-crm

          SERVER-GROUP STATE
          app-group    added
          eos
        )
        executor.register_command(
          "deploy --name=#{resource[:name]} --server-groups=super-crm"
        )
      end

      subject { provider.servergroups = ['app-group', 'super-crm'] }
      it { expect(subject).to eq(['app-group', 'super-crm']) }
    end
  end

  describe '#redeploy_on_refresh' do
    describe 'with default value' do
      before :each do
        [
          'undeploy super-crm-1.1.0 --all-relevant-server-groups',
          'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups --force'
        ].each { |cmd| executor.register_command cmd }
      end
      let(:extended_repl) do
        { :redeploy_on_refresh => true }
      end
      subject { provider.redeploy_on_refresh }
      it { expect(subject).not_to be_nil }
    end

    describe 'with value set to false' do
      before :each do
        [
          'deploy /usr/src/super-crm-1.1.0.war --name=super-crm-1.1.0 --all-server-groups'
        ].each { |cmd| executor.register_command cmd }
      end
      let(:extended_repl) do
        { :redeploy_on_refresh => false }
      end
      subject { provider.redeploy_on_refresh }
      it { expect(subject).not_to be_nil }
    end
  end
end
