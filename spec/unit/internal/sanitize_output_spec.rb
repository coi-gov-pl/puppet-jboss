require 'spec_helper'
require 'json'

describe PuppetX::Coi::Jboss::Internal::Sanitizer do
  let(:instance) { described_class.new }

  [
    'evaluated',
    'deployment-read',
    'ruby',
    'security-domain',
    'root-recursive'
  ].each do |filename|
    describe "for input of #{filename.inspect}" do
      let(:content) { File.read("spec/testing/files/#{filename}.txt") }
      describe 'should parse sanitized output as JSON' do
        subject { JSON.parse(instance.sanitize(content)) }
        it { expect(subject).not_to be_nil }
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
