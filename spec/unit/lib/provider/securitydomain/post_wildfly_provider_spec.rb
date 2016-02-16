require "spec_helper"

describe Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider do
  let(:resource) do
    {
      :name          => 'testing',
      :code          => 'Database',
      :codeflag      => true,
      :moduleoptions =>  {
        'principalsQuery'  => "select 'password' from users u where u.login = ?",
        'hashUserPassword' => false,
      }
    }
  end

  let(:provider) { double('mock', :resource => resource) }
  let(:instance) { described_class.new(provider) }

  describe '#create_parametrized_cmd with post wildfly' do
    subject { instance.make_command_templates }
    let(:cli_command) do
      ["subsystem=security", "security-domain=testing", "authentication=classic", "login-module=UsersRoles:add(code=\"Database\",flag=true,module-options=[(\"hashUserPassword\"=>false),(\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\")])"]

    end
    it { is_expected.to eq cli_command }
  end
end
