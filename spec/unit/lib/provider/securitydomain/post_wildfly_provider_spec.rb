require "spec_helper"

describe Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider do
  let(:resource) { {
    :name          => 'testing',
    :code          => 'Database',
    :codeflag      => 'true',
    :moduleoptions =>  {
      'principalsQuery'   => 'select \'password\' from users u where u.login = ?',
      'hashUserPassword'  => false,
    },
  } }

  let(:provider) { double('mock', :resource => resource) }
  let(:instance) { described_class.new(provider) }

  describe '#create_parametrized_cmd with post wildfly' do
    subject { instance.create_parametrized_cmd }
    it { is_expected.to eq "subsystem=security/security-domain=testing/authentication=classic/login-module=UsersRoles:add(code=Database, flag=true,module-options=[(\"hashUserPassword\" => \"false\"),(\"principalsQuery\" => \"select 'password' from users u where u.login = ?\")]}])" }
  end
end
