require 'spec_helper_puppet'

describe PuppetX::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider do
  let(:resource) do
    {
      :name          => 'testing',
      :code          => 'Database',
      :codeflag      => true,
      :moduleoptions => {
        'principalsQuery'  => "select 'password' from users u where u.login = ?",
        'hashUserPassword' => false
      }
    }
  end

  let(:provider) { double('mock', :resource => resource) }
  let(:compilator) { PuppetX::Coi::Jboss::Internal::CommandCompilator.new }
  let(:instance) { described_class.new(provider, compilator) }

  describe '#create_parametrized_cmd with post wildfly' do
    subject { instance.make_command_templates }

    before :each do
      result = [
        'subsystem=security',
        'security-domain=testing',
        'authentication=classic',
        'login-module=UsersRoles:add(code="Database",flag=true,module-options=[("hashUserPassword"=>false),' \
          '("principalsQuery"=>"select \'password\' from users u where u.login = ?")])'
      ]

      expect(instance).to receive(:make_command_templates).and_return(result)
    end
    let(:cli_command) do
      [
        'subsystem=security',
        'security-domain=testing',
        'authentication=classic',
        'login-module=UsersRoles:add(code="Database",flag=true,module-options=[("hashUserPassword"=>false),' \
          '("principalsQuery"=>"select \'password\' from users u where u.login = ?")])'
      ]
    end
    it { is_expected.to eq cli_command }
  end
end
