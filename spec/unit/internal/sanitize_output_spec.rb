require 'spec_helper'

describe Puppet_X::Coi::Jboss::Internal::Sanitizer do
  let(:instance) { described_class.new }
  let(:content) { File.read('spec/testing/files/evaluated.txt') }

  describe 'should evaluate given input' do
    let(:test_content) { content.dup }
    subject { instance.sanitize(test_content) }
    it do
      expect(subject).to eq File.read('spec/testing/files/sanitized_output.txt')
    end
  end

  describe 'should make no changes' do
    let(:data) do
      File.read "spec/testing/files/#{filename}"
    end
    subject { instance.sanitize(data) }
    describe 'on already_sanitized.txt file' do
      let(:filename) { 'already_sanitized.txt' }
      it { expect(subject).to eq data }
    end
    describe 'on sanitized_output.txt file' do
      let(:filename) { 'sanitized_output.txt' }
      it { expect(subject).to eq data }
    end
  end
end
