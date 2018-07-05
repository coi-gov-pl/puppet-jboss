require 'spec_helper_puppet'

describe PuppetX::Coi::Jboss::Provider::Datasource::PreWildFlyProvider do
  let(:target) { described_class.new(nil) }

  describe 'xa_datasource_properties_wrapper' do
    let(:parameters) { 'david=one,martha=tree' }
    subject { target.xa_datasource_properties_wrapper(parameters) }
    it { expect(subject).to eq('[david=one,martha=tree]') }
  end
end
