require 'spec_helper_puppet'

describe 'Puppet::Type::Jboss_securitydomain::ProviderJbosscli' do
  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999',
      :home       => '/usr/local/jboss-as-7.4.0'
    }
  end

  before :each do
    PuppetX::Coi::Jboss::Configuration.reset_config(mock_values)
  end

  after :each do
    PuppetX::Coi::Jboss::Configuration.reset_config
  end
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
    allow(PuppetX::Coi::Jboss::Configuration).to receive(:read).and_return(
      :jboss_product => 'as'
    )
  end

  let(:executor) { Testing::Mock::ExecutionStateWrapper.new }

  after(:each) { executor.verify_commands_executed }

  describe 'before 6.4' do
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

        executor.register_command(
          '/profile=full/subsystem=security:read-resource(recursive=true)',
          output
        )
        provider.executor executor
      end
      subject { provider.exists? }
      it { expect(subject).to eq(true) }
    end

    describe 'exists? with securitydomain not present in system' do
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

        executor.register_command(
          '/profile=full/subsystem=security:read-resource(recursive=true)',
          output
        )
        provider.executor executor
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe 'exists? with login-modules not present in system' do
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

        executor.register_command(
          '/profile=full/subsystem=security:read-resource(recursive=true)',
          output
        )
        provider.executor executor
      end

      subject { provider.exists? }
      it { expect(subject).to eq(false) }
    end

    describe 'destroy method' do
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

        executor.register_command(
          '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:remove()',
          output
        )
        provider.executor executor
      end

      subject { provider.destroy }
      it { expect(subject).to eq(true) }
    end
  end

  describe 'create methods' do
    describe 'create? when there is no login modules' do
      before :each do
        provider.executor(executor)
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

        executor.register_command(
          '/profile=full/subsystem=security:read-resource(recursive=true)',
          output
        )
        executor.register_command(
          '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=db-auth-default' \
            ':add(code="Database",flag=false,module-options=[("dsJndiName"=>":jboss/datasources/default-db"),' \
            '("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),("principalsQuery"=>' \
            '"select \'password\' from users u where u.login = ?"),("rolesQuery"=>' \
            '"select r.name, \'Roles\' from users")])',
          'asd'
        )
        provider.exists?
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

    describe 'create? when there is no authentication' do
      before :each do
        provider.executor executor
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

        executor.register_command(
          '/profile=full/subsystem=security:read-resource(recursive=true)',
          output
        )
        executor.register_command(
          '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:add()'
        )
        executor.register_command(
          '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=' \
            'db-auth-default:add(code="Database",flag=false,module-options=[("dsJndiName"=>' \
            '":jboss/datasources/default-db"),("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),' \
            '("principalsQuery"=>"select \'password\' from users u where u.login = ?"),("rolesQuery"=>' \
            '"select r.name, \'Roles\' from users")])'
        )
        provider.exists?
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
    describe 'create? when there is no securitydomain' do
      before :each do
        executor.register_command(
          '/profile=full/subsystem=security:read-resource(recursive=true)',
          <<-eos
          {
            "outcome" => "success",
            "result" => {
                "deep-copy-subject-mode" => false,
                "security-domain" => {},
                "vault" => undefined
            }
          }
          eos
        )
        executor.register_command(
          '/profile=full/subsystem=security/security-domain=db-auth-default:add(cache-type=default)',
          'asd'
        )
        executor.register_command(
          '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic:add()',
          'asd'
        )
        executor.register_command(
          '/profile=full/subsystem=security/security-domain=db-auth-default/authentication=classic/login-module=' \
            'db-auth-default:add(code="Database",flag=false,module-options=[("dsJndiName"=>":jboss/datasources/' \
            'default-db"),("hashStorePassword"=>"false"),("hashUserPassword"=>"true"),("principalsQuery"=>' \
            '"select \'password\' from users u where u.login = ?"),("rolesQuery"=>"select r.name, \'Roles\' ' \
            'from users")])',
          'asd'
        )
        provider.executor executor
        provider.exists?
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
