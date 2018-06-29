require 'spec_helper_acceptance'

describe 'jboss::version::as7 smoke test', :if => Testing::Acceptance::JavaPlatform.java6? do
  let(:pp) { example 'jboss::version::as7' }

  before(:all) do
    cleanup_pp = example 'jboss::java::delete_default_java'
    apply_manifest(cleanup_pp, :catch_failures => true)
  end

  it 'should add install JBoss AS 7 with no errors' do
    result = apply_manifest(pp, :catch_failures => true)
    expect(result.exit_code).to be(2)
  end
  it 'should work idempotently' do
    apply_manifest(pp, :catch_changes => true)
  end
  describe service('jboss-as') do
    it { is_expected.to be_running }
  end

  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('jboss-as')
    cleanup_pp = example 'jboss::java::delete_java_6'
    apply_manifest(cleanup_pp, :catch_failures => true)
  end
end
