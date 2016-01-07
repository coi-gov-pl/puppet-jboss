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

  describe 'Puppet::Type::Jboss_securitydomain::ProviderJbosscli' do

    let(:described_class) do
      Puppet::Type.type(:jboss_securitydomain).provider(:jbosscli)
    end
    let(:sample_repl) do
      {
        :name          => 'testing',
        :code          => 'Database',
        :codeflag      => 'true',
        :moduleoptions =>  {
          'principalsQuery'   => 'select \'password\' from users u where u.login = ?',
          'hashUserPassword'  => false,
        },
      }
    end

    let(:resource) do
      raw = sample_repl.dup
      raw[:provider] = described_class.name
      Puppet::Type.type(:jboss_securitydomain).new(raw)
    end

    let(:provider) do
      resource.provider
    end

    before :each do
      allow(provider.class).to receive(:suitable?).and_return(true)
    end

    describe '#create' do
      before :each do
        moduleoptions = 'hashUserPassword => "false",principalsQuery => "select \'password\' from users u where u.login = ?"'

        cmd = "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:add(login-modules=[{code=>\"#{resource[:code]}\",flag=>\"#{resource[:codeflag]}\",module-options=>[#{moduleoptions}]}])"
        compilecmd = "/profile=full-ha/#{cmd}"

        cmd2 = "/subsystem=security/security-domain=#{resource[:name]}:add(cache-type=default)"
        compilecmd2 = "/profile=full-ha/#{cmd2}"

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compilecmd)
        expect(provider).to receive(:compilecmd).with(cmd2).and_return(compilecmd2)

        bringUpName = 'Security Domain Cache Type'
        bringUpName2 = 'Security Domain'
        expected_output = { :result => 'asdfhagfgaskfagbfjbgk' }
        expected_output2 = { :result => 'dffghbdfnmkbsdkj' }


        expect(provider).to receive(:bringUp).with(bringUpName, compilecmd2).and_return(expected_output)
        expect(provider).to receive(:bringUp).with(bringUpName2, compilecmd).and_return(expected_output)
      end
      subject { provider.create }
      it {expect(subject).to eq('asdfhagfgaskfagbfjbgk') }
    end

    describe '#destroy' do
      before :each do
        cmd = "/subsystem=security/security-domain=#{resource[:name]}:remove()"
        compilecmd = "/profile=full-ha/#{cmd}"

        bringDownName = 'Security Domain'
        expected_output = { :result => 'asda'}

        expect(provider).to receive(:compilecmd).with(cmd).and_return(compilecmd)
        expect(provider).to receive(:bringDown).with(bringDownName, compilecmd).and_return(expected_output)
      end
      subject { provider.destroy }
      it { expect(subject).to eq('asda') }
    end

    describe '#preparelines' do
      
    end

  end
end
