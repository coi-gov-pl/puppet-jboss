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
      describe '#create' do
        before :each do
          moduleoptions = 'hashUserPassword => "false",principalsQuery => "select \'password\' from users u where u.login = ?"'

          cmd = 'subsystem=security/security-domain=testing/authentication=classic/login-module=UsersRoles' +
          ':add(code="Database",flag=false,module-options=[("hashUserPassword"=>true),' +
          '("principalsQuery"=>"select \'password\' from users u where u.login = ?")]}])'
          compilecmd = "/profile=full-ha/#{cmd}"

          cmd2 = "/subsystem=security/security-domain=#{resource[:name]}:add(cache-type=default)"
          compilecmd2 = "/profile=full-ha/#{cmd2}"

          expect(provider).to receive(:compilecmd).with(cmd).and_return(compilecmd)
          expect(provider).to receive(:compilecmd).with(cmd2).and_return(compilecmd2)

          bringUpName = 'Security Domain Cache Type'
          bringUpName2 = 'Security Domain'
          expected_output = { :result => 'A mcked value indicating that everythings works just fine' }
          expected_output2 = { :result => 'dffghbdfnmkbsdkj' }


          expect(provider).to receive(:bringUp).with(bringUpName, compilecmd2).and_return(expected_output)
          expect(provider).to receive(:bringUp).with(bringUpName2, compilecmd).and_return(expected_output)
        end
        subject { provider.create }
        it {expect(subject).to eq('A mcked value indicating that everythings works just fine') }
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

      describe '#exist?' do
        before :each do
          cmd = "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:read-resource()"
          compilecmd = "/profile=full-ha/#{cmd}"

          lines = 'asd'

          bringDownName = 'Security Domain'
          content =  <<-eos
          {
              "rolesQuery" => "select r.name, 'Roles' from users u join user_roles ur on ur.user_id = u.id join roles r on r.id = ur.role_id where u.login = ?",
              "hashStorePassword" => "false",
              "principalsQuery" => "select 'haslo' from uzytkownik u where u.login = upper(?)",
              "hashUserPassword" => "false",
              "dsJndiName" => "java:jboss/datasources/datasources_auth"
          }
          eos

          expected_lines =  <<-eos
          {
              "outcome" => "success",
              "result" => {
                  "login-modules" => [{
                      "code" => "Database",
                      "flag" => "required",
                      "module" => undefined,
                      "module-options" => #{content}
                  }],
                  "login-module" => {"Database" => undefined}
              }
          }
          eos

          expected_res = {
            :cmd    => compilecmd,
            :result => res_result,
            :lines  => expected_lines
          }

          expect(provider).to receive(:compilecmd).with(cmd).and_return(compilecmd)
          expect(provider).to receive(:executeWithoutRetry).with(compilecmd).and_return(expected_res)
        end

        subject { provider.exists? }

        context 'with res[:result] => true and existinghash && givenhash are not nil' do
          let(:res_result) { true }

          before :each do
            expect(provider).to receive(:destroy).and_return(nil)
          end

          it { expect(subject).to eq(false) }
        end

        context 'with [:result] => false' do
          let(:res_result) { false }
          it { expect(subject).to eq(false) }
        end
      end
    end

    context 'methods with implementation that run before WildFly 8 or JBoss EAP 6.4 came out' do
      before :each do
        expect(Puppet_X::Coi::Jboss::Configuration).to receive(:is_pre_wildfly?).and_return(true)
      end
      describe '#create' do
        subject { provider.create }
        let(:mocked_result) { 'A mocked result that indicate #create method executed just fine' }
        before :each do
          expect(provider).to receive(:bringUp).twice.and_return({:result => mocked_result})
          expect(provider).to receive(:compilecmd).twice
        end
        it { is_expected.to eq mocked_result }
      end
    end

  end
end
