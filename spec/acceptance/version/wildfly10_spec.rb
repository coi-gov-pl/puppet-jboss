require 'spec_helper_acceptance'

describe 'jboss::version::wildfly10 smoke test', :if => Testing::Acceptance::JavaPlatform.java8? do
  let(:pp) { example 'jboss::version::wildfly10' }

  before(:all) do
    cleanup_pp = example 'jboss::java::delete_default_java'
    apply_manifest(cleanup_pp, :catch_failures => true)
  end

  it 'should install WildFly 10 with no errors' do
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
    cleanup_pp = example 'jboss::java::delete_java_8'
    apply_manifest(cleanup_pp, :catch_failures => true)
  end
end
