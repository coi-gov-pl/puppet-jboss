require "spec_helper"

describe Puppet_X::Coi::Jboss::Internal::LogicCreator do

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
  let(:system_executor) {Puppet_X::Coi::Jboss::Internal::Executor::JbossCommandExecutor.new }
  let(:system_runner) { Puppet_X::Coi::Jboss::Internal::JbossSystemRunner.new(system_executor) }
  let(:runner) { Puppet_X::Coi::Jboss::Internal::JbossRunner.new(system_runner) }
  let(:auditor) { Puppet_X::Coi::Jboss::Internal::JbossSecurityDomainAuditor.new(resource, runner) }

  let(:instance) { described_class.new(auditor, resource, provider) }
  subject { instance.decide }

  describe 'pre wildfly provider' do
    let(:provider) { Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider.new(resource) }

    context '#calculate_state with everything set to true' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new(true, true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([]) }
    end

    context '#calculate_state with everything false' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([["Security Domain Cache Type", "/subsystem=security/security-domain=testing:add(cache-type=default)"], ["Security Domain Authentication", "/subsystem=security/security-domain=testing/authentication=classic:add()"], ["Security Domain Login Modules", "/subsystem=security/security-domain=testing/authentication=classic:add(login-modules=[{code=>\"Database\",flag=>true,module-options=>[\"hashUserPassword\"=>false,\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\"]}])"]]) }
    end

    context '#calculate_state with cache type and authentication set' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new(true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([["Security Domain Login Modules", "/subsystem=security/security-domain=testing/authentication=classic:add(login-modules=[{code=>\"Database\",flag=>true,module-options=>[\"hashUserPassword\"=>false,\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\"]}])"]])}
    end

    context '#calculate_state with cache type' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new(true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([["Security Domain Authentication", "/subsystem=security/security-domain=testing/authentication=classic:add()"], ["Security Domain Login Modules", "/subsystem=security/security-domain=testing/authentication=classic:add(login-modules=[{code=>\"Database\",flag=>true,module-options=>[\"hashUserPassword\"=>false,\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\"]}])"]]) }
    end

  end

  describe 'post wildfly provider' do
    let(:provider) { Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider.new(resource) }

    context '#calculate state with everything set' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new(true, true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([]) }
    end

    context '#calculate state with everything not set' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([["Security Domain Cache Type", "/subsystem=security/security-domain=testing:add(cache-type=default)"], ["Security Domain Authentication", "/subsystem=security/security-domain=testing/authentication=classic:add()"], ["Security Domain Login Modules", "/subsystem=security/security-domain=testing/authentication=classic/login-module=testing:add(code=\"Database\",flag=true,module-options=[(\"hashUserPassword\"=>false),(\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\")])"]]) }

    end

    context '#calculate_state with cache type and authentication set' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new(true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([["Security Domain Login Modules", "/subsystem=security/security-domain=testing/authentication=classic/login-module=testing:add(code=\"Database\",flag=true,module-options=[(\"hashUserPassword\"=>false),(\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\")])"]]) }
    end

    context '#calculate_state with cache type' do
      before(:each) do
        state = Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState.new(true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([["Security Domain Authentication", "/subsystem=security/security-domain=testing/authentication=classic:add()"], ["Security Domain Login Modules", "/subsystem=security/security-domain=testing/authentication=classic/login-module=testing:add(code=\"Database\",flag=true,module-options=[(\"hashUserPassword\"=>false),(\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\")])"]]) }
    end
  end
end
