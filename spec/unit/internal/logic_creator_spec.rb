require 'spec_helper'

describe PuppetX::Coi::Jboss::Internal::LogicCreator do
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
  let(:system_executor) { PuppetX::Coi::Jboss::Internal::Executor::ShellExecutor.new }
  let(:system_runner) { PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper.new(system_executor) }
  let(:runner) { PuppetX::Coi::Jboss::Internal::CliExecutor.new(system_runner) }
  let(:compilator) { PuppetX::Coi::Jboss::Internal::CommandCompilator.new }
  let(:destroyer) { PuppetX::Coi::Jboss::Internal::SecurityDomainDestroyer.new(runner, compilator, resource) }
  let(:auditor) { PuppetX::Coi::Jboss::Internal::SecurityDomainAuditor.new(resource, runner, compilator, destroyer) }

  let(:instance) { described_class.new(auditor, resource, provider, compilator) }
  subject { instance.decide }

  describe 'pre wildfly provider' do
    let(:provider) { PuppetX::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider.new(resource, compilator) }
    describe '#calculate_state with everything set to true' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new(true, true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([]) }
    end

    describe '#calculate_state with everything false' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it do
        expect(subject).to eq(
          [
            [
              'Security Domain Cache Type',
              '/subsystem=security/security-domain=testing:add(cache-type=default)'
            ],
            [
              'Security Domain Login Modules',
              '/subsystem=security/security-domain=testing/authentication=classic:add(login-modules=' \
                '[{code=>"Database",flag=>true,module-options=>["hashUserPassword"=>false,' \
                '"principalsQuery"=>"select \'password\' from users u where u.login = ?"]}])'
            ]
          ]
        )
      end
    end

    describe '#calculate_state with cache type and authentication set' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new(true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it do
        expect(subject).to eq(
          [
            [
              'Security Domain Login Modules',
              '/subsystem=security/security-domain=testing/authentication=classic:add(login-modules=' \
                '[{code=>"Database",flag=>true,module-options=>["hashUserPassword"=>false,' \
                '"principalsQuery"=>"select \'password\' from users u where u.login = ?"]}])'
            ]
          ]
        )
      end
    end

    describe '#calculate_state with cache type' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new(true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it do
        expect(subject).to eq(
          [
            [
              'Security Domain Login Modules',
              '/subsystem=security/security-domain=testing/authentication=classic:add(login-modules=[{code=>' \
                '"Database",flag=>true,module-options=>["hashUserPassword"=>false,"principalsQuery"=>' \
                '"select \'password\' from users u where u.login = ?"]}])'
            ]
          ]
        )
      end
    end
  end

  describe 'post wildfly provider' do
    let(:provider) { PuppetX::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider.new(resource, compilator) }

    describe '#calculate state with everything set' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new(true, true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it { expect(subject).to eq([]) }
    end

    describe '#calculate state with everything not set' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it do
        expect(subject).to eq(
          [
            [
              'Security Domain Cache Type',
              '/subsystem=security/security-domain=testing:add(cache-type=default)'
            ],
            [
              'Security Domain Authentication',
              '/subsystem=security/security-domain=testing/authentication=classic:add()'
            ],
            [
              'Security Domain Login Modules',
              '/subsystem=security/security-domain=testing/authentication=classic/login-module=testing' \
                ':add(code="Database",flag=true,module-options=[("hashUserPassword"=>false),' \
                '("principalsQuery"=>"select \'password\' from users u where u.login = ?")])'
            ]
          ]
        )
      end
    end

    describe '#calculate_state with cache type and authentication set' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new(true, true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it do
        expect(subject).to eq(
          [
            [
              'Security Domain Login Modules',
              '/subsystem=security/security-domain=testing/authentication=classic/login-module=testing:' \
                'add(code="Database",flag=true,module-options=[("hashUserPassword"=>false),' \
                '("principalsQuery"=>"select \'password\' from users u where u.login = ?")])'
            ]
          ]
        )
      end
    end

    describe '#calculate_state with cache type' do
      before(:each) do
        state = PuppetX::Coi::Jboss::Internal::State::SecurityDomainState.new(true)
        expect(auditor).to receive(:fetch_securtydomain_state).and_return(state)
      end
      it do
        expect(subject).to eq(
          [
            [
              'Security Domain Authentication',
              '/subsystem=security/security-domain=testing/authentication=classic:add()'
            ],
            [
              'Security Domain Login Modules',
              '/subsystem=security/security-domain=testing/authentication=classic/login-module=testing' \
                ':add(code="Database",flag=true,module-options=[("hashUserPassword"=>false),' \
                '("principalsQuery"=>"select \'password\' from users u where u.login = ?")])'
            ]
          ]
        )
      end
    end
  end
end
