require 'spec_helper'

describe Puppet_X::Coi::Jboss::Internal::RestExecutor do
  let(:instance) { described_class.new }
  let(:retry_count) { 2 }
  let(:retry_timeout) { 100 }
  let(:runasdomain) { true }
  let(:ctrlcfg) do
    {
      :controller => 'localhost',
      :ctrluser   => 'jboss',
      :ctrlpasswd => 'this is not actually being checked'
    }
  end

  describe '#executeAndGet method' do
    let(:execution) { instance.executeAndGet(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout) }
    context 'with standard case of running JBoss controller' do
      describe 'running a command with miltiple paths and options' do
        let(:cmd) {
          '/subsystem=undertow/server=default-server/http-listener=default' \
          ':read-resource(include-runtime=true)'
        }
      end

      it { expect(execution).not_to throw_error }
      it do
        expect(execution).to eq({
          :result => true,
          :data   => {
            'property-a' => true,
            'property-b' => 5,
            'property-c' => 'string'
          }
        })
      end
    end

    context 'with JBoss controller that returns and error for first time' do
      it { expect(execution).not_to throw_error }
    end
  end

  describe '#executeAndFail method' do
    let(:execution) { instance.executeAndFail(typename, cmd, way, resource) }
    it { expect(execution).not_to throw_error }
  end
end
