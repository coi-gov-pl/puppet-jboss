require 'spec_helper_acceptance'

ok = Testing::Acceptance::JavaPlatform.compatibile_java?('wildfly', '9.0.2.Final')
describe 'jboss::version::wildfly9 smoke test', :if => ok do
  let(:pp) { example 'jboss::version::wildfly9' }

  it 'should install WildFly 9 with no errors' do
    result = apply_manifest(pp, :catch_failures => true)
    expect(result.exit_code).to be(2)
  end
  it 'should work idempotently' do
    apply_manifest(pp, :catch_changes => true)
  end
  describe service('wildfly') do
    it { is_expected.to be_running }
  end
  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('wildfly')
  end
end
