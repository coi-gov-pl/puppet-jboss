require 'spec_helper_acceptance'

describe 'jboss::version::wildfly8 smoke test' do
  let(:pp) { example 'jboss::version::wildfly8' }

  it 'should add install WildFly 8 with no errors' do
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
