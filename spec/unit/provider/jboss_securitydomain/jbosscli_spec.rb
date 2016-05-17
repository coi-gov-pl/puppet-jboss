require 'spec_helper'

context 'mocking default values for SecurityDomain' do
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

  describe 'Puppet::Type::Jboss_securitydomain::ProviderJbosscli' do
    let(:described_class) do
      Puppet::Type.type(:jboss_securitydomain).provider(:jbosscli)
    end
    let(:sample_repl) do
      {
        :name          => 'db-auth-default',
        :code          => 'Database',
        :codeflag      => false,
        :moduleoptions => {
          'dsJndiName' => ':jboss/datasources/default-db',
          'hashStorePassword' => 'false',
          'hashUserPassword' => 'true',
          'principalsQuery' => "select 'password' from users u where u.login = ?",
          'rolesQuery' => "select r.name, 'Roles' from users u join user_roles ur on ur.user_id = u.id join roles r on r.id = ur.role_id where u.login = ?" }
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
      allow(Puppet_X::Coi::Jboss::Configuration).to receive(:read).and_return(:jboss_product => 'as')
    end

    let(:mocked_execution_state_wrapper) { Testing::Mock::ExecutionStateWrapper.new }

    context 'before 6.4' do
      before :each do
      end
      describe 'exists? when everything is set' do
        before :each do
          output = <<-eos
          {
    "outcome" => "success",
    "result" => {
        "deep-copy-subject-mode" => false,
        "security-domain" => {
            "db-auth-default" => {
                "cache-type" => "default",
                "acl" => undefined,
                "audit" => undefined,
                "authentication" => {"classic" => {
                    "login-modules" => [{
                        "code" => "asdasd",
                        "flag" => "required",
                        "module" => undefined,
                        "module-options" => {
                            "dsJndiName" => ":jboss/datasources/default-db",
                            "hashStorePassword" => "false",
                            "hashUserPassword" => "true",
                            "principalsQuery" => "select 'password' from users u where u.login = ?",
                            "rolesQuery" => "select r.name, 'Roles' from users u join user_roles ur on ur.user_id = u.id join roles r on r.id = ur.role_id where u.login = ?"
                        }
                    }],
                    "login-module" => {"db-auth-default" => {
                        "code" => "asdasd",
                        "flag" => "required",
                        "module" => undefined,
                        "module-options" => {
                            "dsJndiName" => ":jboss/datasources/default-db",
                            "hashStorePassword" => "false",
                            "hashUserPassword" => "true",
                            "principalsQuery" => "select 'password' from users u where u.login = ?",
                            "rolesQuery" => "select r.name, 'Roles' from users u join user_roles ur on ur.user_id = u.id join roles r on r.id = ur.role_id where u.login = ?"
                        }
                    }}
                }},
                "authorization" => undefined,
                "identity-trust" => undefined,
                "jsse" => undefined,
                "mapping" => undefined
            }
        },
        "vault" => undefined
    }
  }
          eos

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security:read-resource(recursive=true)',
            true,
            output,
            true)
          provider.execution_state_wrapper = mocked_execution_state_wrapper
        end
        subject { provider.exists? }
        it { expect(subject).to eq(true) }
      end

      context 'exists? with securitydomain not present in system' do
        before :each do
          output = <<-eos
          {
    "outcome" => "success",
    "result" => {
        "deep-copy-subject-mode" => false,
        "other" => {
            "testing" => {
                "cache-type" => "default",
                "acl" => undefined,
                "audit" => undefined,
                "authentication" => undefined,
                "authorization" => undefined,
                "identity-trust" => undefined,
                "jsse" => undefined,
                "mapping" => undefined
            }
        },
        "vault" => undefined
    }
  }
          eos

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security:read-resource(recursive=true)',
            true,
            output,
            true)
          provider.execution_state_wrapper = mocked_execution_state_wrapper
        end

        subject { provider.exists? }
        it { expect(subject).to eq(false) }
      end

      context 'exists? with login-modules not present in system' do
        before :each do
          output = <<-eos
          {
    "outcome" => "success",
    "result" => {
        "deep-copy-subject-mode" => false,
        "security-domain" => {
            "db-auth-default" => {
                "cache-type" => "default",
                "acl" => undefined,
                "audit" => undefined,
                "authentication" => {"classic" => {
                    "login-modules" => [{
                        "code" => "asdasd",
                        "flag" => "required",
                        "module" => undefined,
                        "module-options" => undefined,
                    }],
                    "login-module" => {"db-auth-default" => {
                        "code" => "asdasd",
                        "flag" => "required",
                        "module" => undefined,
                        "module-options" => {
                            "dsJndiName" => ":jboss/datasources/default-db",
                            "hashStorePassword" => "false",
                            "hashUserPassword" => "true",
                            "principalsQuery" => "select 'password' from users u where u.login = ?",
                            "rolesQuery" => "select r.name, 'Roles' from users u join user_roles ur on ur.user_id = u.id join roles r on r.id = ur.role_id where u.login = ?"
                        }
                    }}
                }},
                "authorization" => undefined,
                "identity-trust" => undefined,
                "jsse" => undefined,
                "mapping" => undefined
            }
        },
        "vault" => undefined
    }
  }
          eos

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security:read-resource(recursive=true)',
            true,
            output,
            true)
          provider.execution_state_wrapper = mocked_execution_state_wrapper
        end

        subject { provider.exists? }
        it { expect(subject).to eq(false) }
      end

    context 'after 6.4' do
    end
  end
end
