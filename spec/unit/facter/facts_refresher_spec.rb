require 'spec_helper_puppet'

describe Puppet_X::Coi::Jboss::FactsRefresher do
  context 'basic test to check if fact is deleted' do
    before :each do
      Facter.add(:test_fact) { setcode { 'test value' } }
    end

    after :each do
      fct = Facter.fact :test_fact
      fct.instance_variable_set(:@value, nil)
      fct.instance_variable_set(:@resolves, [])
    end

    describe '#delete_resolves' do
      subject { described_class.delete_resolves(fact) }

      context 'delete selfmade fact' do
        after :each do
          fct = Facter.fact fact
          facter_value = fct.instance_variable_get(:@resolves)
          expect(facter_value).to eq([])
        end

        let(:fact) { :jboss_fact }
        it { expect(subject).to eq([]) }
      end
    end

    describe '#delete value' do
      subject { described_class.delete_value(fact) }

      context '#delete_value selfmade fact' do
        after :each do
          fct = Facter.fact fact
          facter_value = fct.instance_variable_get(:@value)
          expect(facter_value).to eq({})
        end

        let(:fact) { :jboss_fact }
        it { expect(subject).to eq({}) }
      end
    end
  end

  context 'tests for refreshing facts' do
    describe '#refresh_facts' do
      subject { described_class.refresh_facts(facts) }

      context 'refresh facts from correct list of facts' do
        before :each do
          expect(Facter).to receive(:list).and_return(%w[test_fact jboss_test_fact])
          expect(Puppet_X::Coi::Jboss::Configuration).to receive(:read).at_least(1).times.and_return({ :jboss_test_fact => 'test' })
        end
        let(:facts) { [:jboss_test_fact] }
        it { expect(subject).to eq([:jboss_test_fact]) }
      end
    end
  end
end
