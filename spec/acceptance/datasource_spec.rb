require 'spec_helper_acceptance'

describe 'datasource smoke test' do
  let(:baseserver) { example 'jboss' }
  let(:pp) { example 'jboss::datasource' }
  let(:modpp) { example 'jboss::modified::datasource' }

  it 'should install base server with no errors' do
    result = apply_manifest(baseserver, :catch_failures => true)
    expect(result.exit_code).to be(2)
  end
  it 'should add datasource with no errors' do
    result = apply_manifest(pp, :catch_failures => true)
    expect(result.exit_code).to be(2)
  end
  it 'should work idempotently' do
    apply_manifest(pp, :catch_changes => true)
  end
  it 'should change datasource with no errors' do
    result = apply_manifest(modpp, :catch_failures => true)
    expect(result.exit_code).to be(2)
  end
  it 'should work idempotently after changes' do
    apply_manifest(modpp, :catch_changes => true)
  end
  describe service('wildfly') do
    it { is_expected.to be_running }
  end
  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('wildfly')
  end
end
