require 'spec_helper_puppet'

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
        :controller    => '127.0.0.1:9999',
        :ctrluser      => 'root',
        :ctrlpasswd    => 'password',
        :name          => 'db-auth-default',
        :code          => 'Database',
        :codeflag      => false,
        :profile       => 'full',
        :moduleoptions => {
          'dsJndiName'        => ':jboss/datasources/default-db',
          'hashStorePassword' => 'false',
          'hashUserPassword'  => 'true',
          'principalsQuery'   => "select 'password' from users u where u.login = ?",
          'rolesQuery'        => "select r.name, 'Roles' from users"
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
                            "rolesQuery" => "select r.name, 'Roles' from users"
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
                            "rolesQuery" => "select r.name, 'Roles' from users"
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
            true
          )
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
            true
          )
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
                            "rolesQuery" => "select r.name, 'Roles' from users"
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
            true
          )
          provider.execution_state_wrapper = mocked_execution_state_wrapper
        end

        subject { provider.exists? }
        it { expect(subject).to eq(false) }
      end

      context 'destroy method' do
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
                            "rolesQuery" => "select r.name, 'Roles' from users"
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
            '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:remove()',
            true,
            output,
            true
          )
          provider.execution_state_wrapper = mocked_execution_state_wrapper
        end

        subject { provider.destroy }
        it { expect(subject).to eq(true) }
      end
    end

    context 'create methods' do
      context 'create? when there is no login modules' do
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
                            "rolesQuery" => "select r.name, 'Roles' from users"
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
            true
          )
          provider.execution_state_wrapper = mocked_execution_state_wrapper
          provider.exists?

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=db-auth-default' \
              ':add(code="Database",flag=false,module-options=[("dsJndiName"=>":jboss/datasources/default-db"),' \
              '("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),("principalsQuery"=>' \
              '"select \'password\' from users u where u.login = ?"),("rolesQuery"=>' \
              '"select r.name, \'Roles\' from users")])',
            true,
            'asd',
            true
          )
        end

        subject { provider.create }
        it do
          expect(subject).to eq(
            [
              [
                'Security Domain Login Modules',

                '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=' \
                  'db-auth-default:add(code="Database",flag=false,module-options=[("dsJndiName"=>' \
                  '":jboss/datasources/default-db"),("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),' \
                  '("principalsQuery"=>"select \'password\' from users u where u.login = ?"),("rolesQuery"=>' \
                  '"select r.name, \'Roles\' from users")])'
              ]
            ]
          )
        end
      end

      context 'create? when there is no authentication' do
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
            true
          )
          provider.execution_state_wrapper = mocked_execution_state_wrapper
          provider.exists?

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:add()',
            true,
            'asd',
            true
          )

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=' \
              'db-auth-default:add(code="Database",flag=false,module-options=[("dsJndiName"=>' \
              '":jboss/datasources/default-db"),("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),' \
              '("principalsQuery"=>"select \'password\' from users u where u.login = ?"),("rolesQuery"=>' \
              '"select r.name, \'Roles\' from users")])',
            true,
            'asd',
            true
          )
        end

        subject { provider.create }
        it do
          expect(subject).to eq(
            [
              [
                'Security Domain Authentication',
                '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:add()'
              ],
              [
                'Security Domain Login Modules',
                '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=' \
                  'db-auth-default:add(code="Database",flag=false,module-options=[("dsJndiName"=>":jboss/datasources/' \
                  'default-db"),("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),("principalsQuery"=>' \
                  '"select \'password\' from users u where u.login = ?"),("rolesQuery"=>"select r.name, \'Roles\' ' \
                  'from users")])'
              ]
            ]
          )
        end
      end
      context 'create? when there is no securitydomain' do
        before :each do
          output = <<-eos
          {
    "outcome" => "success",
    "result" => {
        "deep-copy-subject-mode" => false,
        "security-domain" => {
            "other" => {
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
                            "rolesQuery" => "select r.name, 'Roles' from users "
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
            true
          )
          provider.execution_state_wrapper = mocked_execution_state_wrapper
          provider.exists?

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security/security-domain=db-auth-default:add(cache-type=default)',
            true,
            'asd',
            true
          )

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:add()',
            true,
            'asd',
            true
          )

          mocked_execution_state_wrapper.register_command(
            '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=' \
              'db-auth-default:add(code="Database",flag=false,module-options=[("dsJndiName"=>":jboss/datasources/' \
              'default-db"),("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),("principalsQuery"=>' \
              '"select \'password\' from users u where u.login = ?"),("rolesQuery"=>"select r.name, \'Roles\' ' \
              'from users")])',
            true,
            'asd',
            true
          )
        end

        subject { provider.create }
        it do
          expect(subject).to eq(
            [
              [
                'Security Domain Cache Type',
                '/profile=full/subsystem=security/security-domain=db-auth-default:add(cache-type=default)'
              ],
              [
                'Security Domain Authentication',
                '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:add()'
              ],
              [
                'Security Domain Login Modules',
                '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=' \
                  'db-auth-default:add(code="Database",flag=false,module-options=[("dsJndiName"=>":jboss/datasources' \
                  '/default-db"),("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),("principalsQuery"=>' \
                  '"select \'password\' from users u where u.login = ?"),("rolesQuery"=>"select r.name, \'Roles\' ' \
                  'from users")])'
              ]
            ]
          )
        end
      end
    end
  end
end
