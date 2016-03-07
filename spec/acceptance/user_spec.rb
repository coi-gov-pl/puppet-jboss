require 'spec_helper_acceptance'

describe 'user.pp smoke test', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  let(:baseserver) { Testing::Acceptance::SmokeTestReader.smoke_pp :init }
  let(:pp) { Testing::Acceptance::SmokeTestReader.smoke_pp :user }

  it 'should work idempotently with no errors' do
    # First install base server
    apply_manifest(baseserver, :catch_failures => true)

    # Apply target manifest
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end
  describe service('wildfly') do
    it { is_expected.to be_running }
  end
  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('wildfly')
  end
end
