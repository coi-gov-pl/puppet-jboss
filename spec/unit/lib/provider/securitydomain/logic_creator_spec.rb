require "spec_helper"

describe Puppet_X::Coi::Jboss::Provider::SecurityDomain::LogicCreator do
  let(:instance) { described_class.new }

  describe 'for pre wildfly' do
    before :each do
    end

    subject { instance.prepare_commands_for_ensure() }
  end
end
