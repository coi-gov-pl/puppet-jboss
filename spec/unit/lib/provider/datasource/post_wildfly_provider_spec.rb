require 'spec_helper_puppet'

describe PuppetX::Coi::Jboss::Provider::Datasource::PostWildFlyProvider do
  let(:xa) { false }
  let(:jta) { true }
  let(:provider) { double('Provider') }
  before do
    allow(provider).to receive(:xa?).and_return(xa)
    allow(provider).to receive(:getattrib).and_return(jta)
  end
  let(:target) { described_class.new(provider) }

  describe 'xa_datasource_properties_wrapper' do
    let(:parameters) { 'david=one,martha=tree' }
    subject { target.xa_datasource_properties_wrapper(parameters) }
    it { expect(subject).to eq('{david=one,martha=tree}') }
  end

  describe 'jta' do
    subject { target.jta }
    it { expect(subject).to eq('true') }
  end
end
