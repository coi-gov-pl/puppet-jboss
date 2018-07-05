require 'spec_helper_puppet'

describe 'PuppetX::Coi.require_relative' do
  def classcheck
    defined?(UnitFile::ToBeLoaded)
  end
  let(:required) { 'file/to_be_loaded' }
  subject { PuppetX::Coi.require_relative(required) }
  before(:all) { expect(classcheck).to be nil }
  it { expect { subject }.not_to raise_error }
  after(:all) { expect(classcheck).not_to be nil }
end
