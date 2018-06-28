require 'spec_helper_acceptance'

describe 'jboss::version::wildfly10 smoke test' do
  let(:pp) { example 'jboss::version::wildfly10' }

  shared_examples 'a properly working class on a platform with supported Java version' do
    it 'should install WildFly 10 with no errors' do
      result = apply_manifest(pp, :catch_failures => true)
      expect(result.exit_code).to be(2)
    end
    it 'should work idempotently' do
      apply_manifest(pp, :catch_changes => true)
    end
    describe service('wildfly') do
      it { is_expected.to be_running }
    end
  end

  if fact('osfamily') == 'RedHat' && fact('operatingsystemmajrelease') >= '7'
    it_behaves_like 'a properly working class on a platform with supported Java version'
  elsif fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') >= '9'
    it_behaves_like 'a properly working class on a platform with supported Java version'
  elsif fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') >= '15.10'
    it_behaves_like 'a properly working class on a platform with supported Java version'
  else
    it 'should install WildFly, but it should not start due to lack of Java 8' do
      apply_manifest(pp, :acceptable_exit_codes => [2, 4])
    end
    describe service('wildfly') do
      it { is_expected.not_to be_running }
    end
  end

  after(:all) do
    extend Testing::Acceptance::Cleaner
    remove_jboss_installation('wildfly')
  end
end
