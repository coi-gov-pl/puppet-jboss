require 'spec_helper'

describe Puppet_X::Coi::Jboss::FactsRefresher do
  context 'basic test to check if fact is deleted' do
    before :each do
      fct = Facter.add(:test_fact) { setcode { 'test value' } }
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

        let(:fact) { 'jboss_fact' }
        it { expect(subject).to eq([]) }
      end

      context '#delete system fact' do

        let(:fact) { 'test_fact' }
        it { expect { subject }.to raise_error(Puppet::Error, 'You can only delete fact that are made by jboss_module(start with jboss_)') }
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

        let(:fact) { 'jboss_fact' }
        it { expect(subject).to eq({}) }
      end

      context '#delete_value of system fact' do
        let(:fact) { 'test_fact' }

        it { expect { subject }.to raise_error(Puppet::Error, 'You can only delete fact that are made by jboss_module(start with jboss_)') }
      end
    end
  end
end
