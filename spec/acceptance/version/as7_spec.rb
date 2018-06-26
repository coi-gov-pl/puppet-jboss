require 'spec_helper_acceptance'

java6_possible = JAVA6_PLATFORMS.any? do |c|
  os = fact('operatingsystem')
  rel = fact('operatingsystemmajrelease')
  c == "#{os} #{rel}"
end

describe 'jboss::version::as7 smoke test', :if => java6_possible do
  let(:pp) { example 'jboss::version::as7' }

  before(:all) do
    cleanup_pp = example 'jboss::version::as7::rmjava_default'
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
    cleanup_pp = example 'jboss::version::as7::rmjava_as7'
    apply_manifest(cleanup_pp, :catch_failures => true)
  end
end
