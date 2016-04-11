require "spec_helper"

context "mocking default values for SecurityDomain" do

  let(:mock_values) do
    {
      :product    => 'jboss-eap',
      :version    => '6.4.0.GA',
      :controller => '127.0.0.1:9999',
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
        :moduleoptions =>  {
          'principalsQuery'   => 'select \'password\' from users u where u.login = ?',
          'hashUserPassword'  => true,
        },
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
    end

    context 'methods with implementation for modern JBoss servers, that means after releases of WildFly 8 or JBoss EAP 6.4' do

      before :each do
        provider.instance_variable_set(:@impl, Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider.new(provider))
      end

      describe '#create' do
        before :each do

          provider.instance_variable_set(:@impl, Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider.new(provider))

          provider.instance_variable_set(:@auth, false)

          provider.instance_variable_set(:@compilator, Puppet_X::Coi::Jboss::Internal::JbossCompilator.new)

          login_modules_command = 'subsystem=security/security-domain=testing/authentication=classic/login-module=UsersRoles' +
          ':add(code="Database",flag=false,module-options=[("hashUserPassword"=>true),' +
          '("principalsQuery"=>"select \'password\' from users u where u.login = ?")])'
          compiled_login_modules_command = "/profile=full-ha/#{login_modules_command}"

          cache_command = "/subsystem=security/security-domain=#{resource[:name]}:add(cache-type=default)"
          compiled_cache_command = "/profile=full-ha/#{cache_command}"

          auth_command = "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:add()"

          compiled_auth_command = "/profile=full-ha/#{auth_command}"

          list_result = ['subsystem=security', 'security-domain=testing', 'authentication=classic', "login-module=UsersRoles:add(code=\"Database\",flag=false,module-options=[(\"hashUserPassword\"=>true),(\"principalsQuery\"=>\"select 'password' from users u where u.login = ?\")])"]

          # create_parametrized_cmd
          expect(provider).to receive(:create_parametrized_cmd).and_return(list_result)

          # cache command
          expect(provider).to receive(:compilecmd).with(cache_command).and_return(compiled_cache_command)

          # auth
          expect(provider).to receive(:compilecmd).with(auth_command).and_return(compiled_auth_command)

          # login modules
          expect(provider).to receive(:compilecmd).with(login_modules_command).and_return(compiled_login_modules_command)


          bringUpName = 'Security Domain Cache Type'
          bringUpName2 = 'Security Domain Authentication'
          bringUpName3 = 'Security Domain'

          expected_output = { :result => 'A mocked value indicating that everythings works just fine' }
          expected_output2 = { :result => 'dffghbdfnmkbsdkj' }


          expect(provider).to receive(:bringUp).with(bringUpName, compiled_cache_command).and_return(expected_output)

          expect(provider).to receive(:bringUp).with(bringUpName2, compiled_auth_command).and_return(expected_output)

          expect(provider).to receive(:bringUp).with(bringUpName3, compiled_login_modules_command).and_return(expected_output)

        end
        subject { provider.create }

        it {expect(subject).to eq('A mocked value indicating that everythings works just fine') }
      end

      describe '#destroy' do
        before :each do
          cmd = "/subsystem=security/security-domain=#{resource[:name]}:remove()"
          compilecmd = "/profile=full-ha/#{cmd}"

          bringDownName = 'Security Domain'
          expected_output = { :result => 'A mocked value indicating that #destroy method runned without any problems'}

          expect(provider).to receive(:compilecmd).with(cmd).and_return(compilecmd)
          expect(provider).to receive(:bringDown).with(bringDownName, compilecmd).and_return(expected_output)
        end
        subject { provider.destroy }
        it { expect(subject).to eq('A mocked value indicating that #destroy method runned without any problems') }
      end
    end

    context 'methods with implementation that run before WildFly 8 or JBoss EAP 6.4 came out' do
      describe '#create' do

        subject { provider.create }
        let(:mocked_result) { 'A mocked result that indicate #create method executed just fine' }

        before :each do

          provider.instance_variable_set(:@impl, Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider.new(provider))
          provider.instance_variable_set(:@compilator, Puppet_X::Coi::Jboss::Internal::JbossCompilator.new)

          expect(provider).to receive(:bringUp).exactly(3).times.and_return({:result => mocked_result})
          expect(provider).to receive(:compilecmd).exactly(3).times

        end
        it { is_expected.to eq mocked_result }
      end

      describe '#exists? when authentication is present' do
        subject { provider.exists? }


        before :each do

          cmd = "/subsystem=security:read-resource(recursive=true)"
          data = {
              "outcome" => "success",
              "result" => {
                  "deep-copy-subject-mode" => false,
                  "security-domain" => {
                      "testing" => {
                          "cache-type" => "default",
                          "acl" => nil,
                          "audit" => nil,
                          "authentication" => {"classic" => {
                            "login-modules" => [{
                                "code" => "Database",
                                "flag" => "optional",
                                "module" => nil,
                                "module-options" => {
                                  "rolesQuery" => "select r.name, \'Roles\' from users u
                                                  join user_roles ur on ur.user_id = u.id
                                                  join roles r on r.id = ur.role_id
                                                  where u.login = ?'",
                                  "hashStorePassword" => "false",
                                  "principalsQuery" => "select \'password\' from users u where u.login = ?",
                                  "hashUserPassword" => "false",
                                  "dsJndiName" => "java:jboss/datasources/datasources_auth"
                                }
                            }],
                          }},
                          "authorization" => nil,
                          "identity-trust" => nil,
                          "jsse" => nil,
                          "mapping" => nil
                      },
                  },
                  "vault" => nil
              }
          }
          compiledcmd = "/profile=full-ha/subsystem=security:read-resource(recursive=true)"


          expected_res = {
            :cmd    => compiledcmd,
            :result => res_result,
            :lines  => data
          }

          expect(provider).to receive(:compilecmd).with(cmd).and_return(compiledcmd)
          expect(provider).to receive(:executeWithoutRetry).with(compiledcmd).and_return(expected_res)
          expect(provider).to receive(:preparelines).with(data).and_return(expected_res)
          expect(provider).to receive(:eval).with(expected_res).and_return(data)

        end
        let(:res_result) { true }
        it { is_expected.to eq(true) }
      end

      context 'result of exists? is false' do

        subject { provider.exists? }

        before :each do
          compiledcmd = "/profile=full-ha/subsystem=security:read-resource(recursive=true)"

          data = {
              "outcome" => "failed",
              "result" => {}
          }

          expected_res = {
            :cmd    => compiledcmd,
            :result => res_result,
            :lines  => data
          }

          expect(provider).to receive(:compilecmd).with('/subsystem=security:read-resource(recursive=true)').and_return(compiledcmd)
          expect(provider).to receive(:executeWithoutRetry).with(compiledcmd).and_return(expected_res)
        end

        let(:res_result) { false }
        it { is_expected.to eq(false) }
      end
    end
  end
end
