require 'spec_helper_acceptance'

describe 'jboss::as7 smoke test', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  let(:pp) { Testing::Acceptance::SmokeTestReader.smoke_pp :'jboss::as7' }

  it 'should add install JBoss AS 7 with no errors' do
    apply_manifest(pp, :expect_changes => true, :trace => true)
  end
  it 'should work idempotently' do
    apply_manifest(pp, :catch_changes  => true, :trace => true)
  end
  describe service('jboss-as') do
    it { is_expected.to be_running }
  end
  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('jboss-as')
  end
end
