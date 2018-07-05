require 'spec_helper'

describe PuppetX::Coi do
  describe '#require_relative' do
    let(:target) { 'mocked/file' }
    subject { PuppetX::Coi.require_relative(target) }
    let(:test_stmt) do
      subject
      NonExistentInAnyContextClassUsedOnlyForTesting.new.test
    end

    it { expect { subject }.not_to raise_error }
    it { expect(test_stmt).to eq(42) }
  end
end
