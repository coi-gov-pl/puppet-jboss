require 'spec_helper_acceptance'

SUPPORTED_OS = %w[centos-6 ol-6 ubuntu-14.04 debian-7].freeze
OS = "#{fact('operatingsystem').downcase}-#{fact('operatingsystemmajrelease')}".freeze

describe 'jboss::as7 smoke test' do
  if !SUPPORTED_OS.include?(OS)
    skip 'JBoss AS 7 example is only suited for older OS\'s like: ubuntu-14.04, centos-6, ol-6 and debian-7'
  else
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

end
