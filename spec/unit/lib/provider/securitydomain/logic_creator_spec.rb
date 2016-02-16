require "spec_helper"

describe Puppet_X::Coi::Jboss::Provider::SecurityDomain::LogicCreator do
  let(:instance) { described_class.new }

  describe 'for pre wildfly' do
    before :each do
      let(:data) { { :data => 'asd'} }
      instance.instance_variable_set(:@state, false)
    end
  end
end
