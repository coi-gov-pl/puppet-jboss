require 'spec_helper'

describe Puppet_X::Coi::Jboss::Internal::Sanitizer do

  let(:instance) { described_class.new }
  let(:file_location) { File.dirname(__FILE__) }
  let(:content) { File.read("#{file_location}/../../testing/files/evaluated.txt") }

  context 'Should evaluate given input' do
    let(:test_content) { content.dup }
    subject { instance.sanitize(test_content) }
    it { expect(subject).to eq("{\n      \"outcome\" => \"success\",\n      \"result\" => {\n          \"deep-copy-subject-mode\" => false,\n          \"vault\" => undefined,\n          \"security-domain\" => {\n              \"jboss-web-policy\" => {\n                  \"acl\" => undefined,\n                  \"audit\" => undefined,\n                  \"authentication\" => undefined,\n                  \"cache-type\" => \"default\",\n                  \"identity-trust\" => undefined,\n                  \"jsse\" => undefined,\n                  \"mapping\" => undefined,\n                  \"authorization\" => {\"classic\" => {\"policy-modules\" => [{\n                      \"code\" => \"Delegating\",\n                      \"flag\" => \"required\",\n                      \"module-options\" => undefined\n                  }]}}\n              },\n              \"other\" => {\n                  \"acl\" => undefined,\n                  \"audit\" => undefined,\n                  \"authorization\" => undefined,\n                  \"cache-type\" => \"default\",\n                  \"identity-trust\" => undefined,\n                  \"jsse\" => undefined,\n                  \"mapping\" => undefined,\n                  \"authentication\" => {\"classic\" => {\"login-modules\" => [\n                      {\n                          \"code\" => \"Remoting\",\n                          \"flag\" => \"optional\",\n                          \"module-options\" => [{'password-stacking' => 'useFirstPass'}]\n                      },\n                      {\n                          \"code\" => \"RealmUsersRoles\",\n                          \"flag\" => \"required\",\n                          \"module-options\" => [\n                              {'usersProperties' => '${jboss.server.config.dir}/application-users.properties'},\n                              {'rolesProperties' => '${jboss.server.config.dir}/application-roles.properties'},\n                              {'realm' => 'ApplicationRealm'},\n                              {'password-stacking' => 'useFirstPass'}\n                          ]\n                      }\n                  ]}}\n              },\n              \"jboss-ejb-policy\" => {\n                  \"acl\" => undefined,\n                  \"audit\" => undefined,\n                  \"authentication\" => undefined,\n                  \"cache-type\" => \"default\",\n                  \"identity-trust\" => undefined,\n                  \"jsse\" => undefined,\n                  \"mapping\" => undefined,\n                  \"authorization\" => {\"classic\" => {\"policy-modules\" => [{\n                      \"code\" => \"Delegating\",\n                      \"flag\" => \"required\",\n                      \"module-options\" => undefined\n                  }]}}\n              }\n          }\n      }\n  }\n") }
  end

  context 'should make no changes' do
      let(:data) { '"other" => {
          "acl" => undefined,
          "audit" => undefined,
          "authorization" => undefined,
          "cache-type" => "default",
          "identity-trust" => undefined,
          "jsse" => undefined,
          "mapping" => undefined,
          "authentication" => {"classic" => {"login-modules" => [
              {
                  "code" => "Remoting",
                  "flag" => "optional",
                  "module-options" => [{"password-stacking" => "useFirstPass"}]
              },
              {
                  "code" => "RealmUsersRoles",
                  "flag" => "required",
                  "module-options" => [
                      {"usersProperties" => "${jboss.server.config.dir}/application-users.properties"},
                      {"rolesProperties" => "${jboss.server.config.dir}/application-roles.properties"},
                      {"realm" => "ApplicationRealm"},
                      {"password-stacking" => "useFirstPass"}
                  ]
              }
          ]}}
      },'}
    subject { instance.sanitize(data) }
    it { expect(subject).to eq(data) }
  end
end
