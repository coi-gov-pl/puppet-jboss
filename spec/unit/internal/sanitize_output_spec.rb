require 'spec_helper'

describe PuppetX::Coi::Jboss::Internal::Sanitizer do
  let(:instance) { described_class.new }

  [
    'evaluated',
    'deployment-read',
    'ruby',
    'security-domain'
  ].each do |filename|
    describe "sanitizing input of #{filename.inspect}" do
      let(:content) { File.read("spec/testing/files/#{filename}.txt") }
      let(:sanitized) { File.read("spec/testing/files/#{filename}-sanitized.json") }
      subject { instance.sanitize(content) }
      it do
        expect(subject).to eq sanitized
      end
    end
  end

  describe 'should make no changes' do
    let(:data) do
      File.read "spec/testing/files/#{filename}"
    end
    subject { instance.sanitize(data) }
    describe 'on already-sanitized.json file' do
      let(:filename) { 'already-sanitized.json' }
      it { expect(subject).to eq data }
    end
    describe 'on evaluated-sanitized.txt file' do
      let(:filename) { 'evaluated-sanitized.json' }
      it { expect(subject).to eq data }
    end
  end
end
