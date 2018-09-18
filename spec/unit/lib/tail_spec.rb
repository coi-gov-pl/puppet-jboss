require 'spec_helper'

describe PuppetX::Coi::Jboss::Tail do
  let(:file) { File.new('spec/testing/files/root-recursive.txt') }
  let(:instance) { described_class.new(file) }
  subject { instance.get(n) }

  describe 'reading 4 last lines' do
    subject { instance.get(4) }
    it { is_expected.to eq "        },\n        \"system-property\" => undefined\n    }\n}\n" }
  end

  describe 'counting \n on 100 last lines read' do
    subject { instance.get(100).split("\n").size }
    it { is_expected.to eq 100 }
  end
end
