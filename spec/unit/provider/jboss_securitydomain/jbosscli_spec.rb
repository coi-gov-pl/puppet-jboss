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
        :name          => 'testing',
        :code          => 'Database',
        :codeflag      => false,
        :moduleoptions => {
          'principalsQuery'   => 'select \'password\' from users u where u.login = ?',
          'hashUserPassword'  => true
        }
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
      describe 'exists?' do
        before :each do
          output = <<-eos
          \n    \"outcome\" => \"success\",\n    \"result\" => {\n        \"deep-copy-subject-mode\" => false,\n        \"security-domain\" => {\n            \"other\" => {\n                \"cache-type\" => \"default\",\n                \"acl\" => undefined,\n                \"audit\" => undefined,\n                \"authentication\" => {\"classic\" => {\n                    \"login-modules\" => [\n                        {\n                            \"code\" => \"Remoting\",\n                            \"flag\" => \"optional\",\n                            \"module\" => undefined,\n                            \"module-options\" => {\"password-stacking\" => \"useFirstPass\"}\n                        },\n                        {\n                            \"code\" => \"RealmDirect\",\n                            \"flag\" => \"required\",\n                            \"module\" => undefined,\n                            \"module-options\" => {\"password-stacking\" => \"useFirstPass\"}\n                        }\n                    ],\n                    \"login-module\" => {\n                        \"Remoting\" => {\n                            \"code\" => \"Remoting\",\n                            \"flag\" => \"optional\",\n                            \"module\" => undefined,\n                            \"module-options\" => {\"password-stacking\" => \"useFirstPass\"}\n                        },\n                        \"RealmDirect\" => {\n                            \"code\" => \"RealmDirect\",\n                            \"flag\" => \"required\",\n                            \"module\" => undefined,\n                            \"module-options\" => {\"password-stacking\" => \"useFirstPass\"}\n                        }\n                    }\n                }},\n                \"authorization\" => undefined,\n                \"identity-trust\" => undefined,\n                \"jsse\" => undefined,\n                \"mapping\" => undefined\n            },\n            \"jboss-web-policy\" => {\n                \"cache-type\" => \"default\",\n                \"acl\" => undefined,\n                \"audit\" => undefined,\n                \"authentication\" => undefined,\n                \"authorization\" => {\"classic\" => {\n                    \"policy-modules\" => [{\n                        \"code\" => \"Delegating\",\n                        \"flag\" => \"required\",\n                        \"module\" => undefined,\n                        \"module-options\" => undefined\n                    }],\n                    \"policy-module\" => {\"Delegating\" => {\n                        \"code\" => \"Delegating\",\n                        \"flag\" => \"required\",\n                        \"module\" => undefined,\n                        \"module-options\" => undefined\n                    }}\n                }},\n                \"identity-trust\" => undefined,\n                \"jsse\" => undefined,\n                \"mapping\" => undefined\n            },\n            \"jboss-ejb-policy\" => {\n                \"cache-type\" => \"default\",\n                \"acl\" => undefined,\n                \"audit\" => undefined,\n                \"authentication\" => undefined,\n                \"authorization\" => {\"classic\" => {\n                    \"policy-modules\" => [{\n                        \"code\" => \"Delegating\",\n                        \"flag\" => \"required\",\n                        \"module\" => undefined,\n                        \"module-options\" => undefined\n                    }],\n                    \"policy-module\" => {\"Delegating\" => {\n                        \"code\" => \"Delegating\",\n                        \"flag\" => \"required\",\n                        \"module\" => undefined,\n                        \"module-options\" => undefined\n                    }}\n                }},\n                \"identity-trust\" => undefined,\n                \"jsse\" => undefined,\n                \"mapping\" => undefined\n            },\n            \"db-auth-default\" => {\n                \"cache-type\" => \"default\",\n                \"acl\" => undefined,\n                \"audit\" => undefined,\n                \"authentication\" => {\"classic\" => {\n                    \"login-modules\" => [{\n                        \"code\" => \"Database\",\n                        \"flag\" => \"required\",\n                        \"module\" => undefined,\n                        \"module-options\" => {\n                            \"dsJndiName\" => \"java:jboss/datasources/default-db\",\n                            \"hashStorePassword\" => \"false\",\n                            \"hashUserPassword\" => \"false\",\n                            \"principalsQuery\" => \"select 'password' from users u where u.login = ?\",\n                            \"rolesQuery\" => \"select r.name, 'Roles' from users u join user_roles ur on ur.user_id = u.id join roles r on r.id = ur.role_id where u.login = ?\"\n                        }\n                    }],\n                    \"login-module\" => {\"db-auth-default\" => {\n                        \"code\" => \"Database\",\n                        \"flag\" => \"required\",\n                        \"module\" => undefined,\n                        \"module-options\" => {\n                            \"dsJndiName\" => \"java:jboss/datasources/default-db\",\n                            \"hashStorePassword\" => \"false\",\n                            \"hashUserPassword\" => \"false\",\n                            \"principalsQuery\" => \"select 'password' from users u where u.login = ?\",\n                            \"rolesQuery\" => \"select r.name, 'Roles' from users u join user_roles ur on ur.user_id = u.id join roles r on r.id = ur.role_id where u.login = ?\"\n                        }\n                    }}\n                }},\n                \"authorization\" => undefined,\n                \"identity-trust\" => undefined,\n                \"jsse\" => undefined,\n                \"mapping\" => undefined\n            }\n        },\n        \"vault\" => undefined\n    }\n}\n
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
    end

    context 'after 6.4' do
    end
  end
end
