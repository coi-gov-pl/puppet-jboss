require 'spec_helper_acceptance'

describe 'deploy.pp smoke test', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  let(:baseserver) { Testing::Acceptance::SmokeTestReader.smoke_pp :init }
  let(:pp) { Testing::Acceptance::SmokeTestReader.smoke_pp :deploy }

  it 'should install base server with no errors' do
    apply_manifest(baseserver, :catch_failures => true)
  end
  it 'should add resource adapter with no errors' do
    apply_manifest(pp, :catch_failures => true)
  end
  context 'verifing idempotency' do
    before(:each) { skip('This not work, GH issue: coi-gov-pl/puppet-jboss#71') }
    it 'should work idempotently' do
      apply_manifest(pp, :catch_changes  => true)
    end
  end
  describe service('wildfly') do
    it { is_expected.to be_running }
  end
  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('wildfly')
  end
end
