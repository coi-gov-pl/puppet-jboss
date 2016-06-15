require "spec_helper"

describe Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider do
  let(:resource) do
    {
      :name          => 'testing-is-awesome',
      :code          => 'DB',
      :codeflag      => false,
      :moduleoptions =>  {
        'hashUserPassword' => true,
        'principalsQuery'  => 'select passwd from users where login = ?',
      }
    }
  end

  let(:provider) { double('mock', :resource => resource) }
  let(:compilator) { Puppet_X::Coi::Jboss::Internal::CommandCompilator.new }
  let(:instance) { described_class.new(provider, compilator) }

  describe '#create_parametrized_cmd with pre wildfly' do
    subject { instance.make_command_templates }

    before :each do
      result = ["subsystem=security", "security-domain=testing-is-awesome", "authentication=classic:add(login-modules=[{code=>\"DB\",flag=>false,module-options=>[\"hashUserPassword\"=>true,\"principalsQuery\"=>\"select passwd from users where login = ?\"]}])"]
      expect(instance).to receive(:make_command_templates).and_return(result)
    end
    let(:cli_command) do
      ["subsystem=security", "security-domain=testing-is-awesome", "authentication=classic:add(login-modules=[{code=>\"DB\",flag=>false,module-options=>[\"hashUserPassword\"=>true,\"principalsQuery\"=>\"select passwd from users where login = ?\"]}])"]
    end
    it { is_expected.to eq cli_command }
  end
end
