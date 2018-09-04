require 'spec_helper_acceptance'

ok = Testing::Acceptance::JavaPlatform.compatibile_java?('wildfly', '8.2.1.Final')
describe 'jboss::version::wildfly8 smoke test', :if => ok do
  let(:pp) { example 'jboss::version::wildfly8' }

  it 'should install WildFly 8 with no errors' do
    result = apply_manifest(pp, :catch_failures => true)
    expect(result.exit_code).to be(2)
  end
  it 'should work idempotently', :unless => fact('osfamily') == 'Debian' do
    apply_manifest(pp, :catch_changes => true)
  end
  describe service('wildfly'), :unless => fact('osfamily') == 'Debian' do
    it { is_expected.to be_running }
  end
  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('wildfly')
  end
end
