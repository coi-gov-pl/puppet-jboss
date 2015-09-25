require 'spec_helper'
require 'puppet_x/coi/jboss/provider/datasource/pre_wildfly_provider'

describe Puppet_X::Coi::Jboss::Provider::Datasource::PreWildFlyProvider do

  let(:target) { described_class.new(nil) }

  describe 'xa_datasource_properties_wrapper' do
    let(:parameters) { 'david=one,martha=tree' }
    subject { target.xa_datasource_properties_wrapper(parameters) }
    it { expect(subject).to eq('[david=one,martha=tree]') }
  end
end