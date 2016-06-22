require 'spec_helper_acceptance'

describe 'jboss::wildfly10 smoke test', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  let(:pp) { Testing::Acceptance::SmokeTestReader.smoke_pp :'jboss::wildfly10' }

  it 'should add install WildFly 10 with no errors' do
    apply_manifest(pp, :expect_changes => true, :trace => true)
  end
  it 'should work idempotently' do
    apply_manifest(pp, :catch_changes  => true, :trace => true)
  end
  describe service('wildfly') do
    it { is_expected.to be_running }
  end
  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('wildfly')
  end
end
