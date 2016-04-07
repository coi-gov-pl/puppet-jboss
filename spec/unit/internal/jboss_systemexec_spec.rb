require 'spec_helper'
require 'os'

describe Puppet_X::Coi::Jboss::Internal::JbossSystemExec do

  describe '#exec_command' do

      let(:instance) { described_class.new }
      subject { instance.exec_command(cmd) }

      describe 'with correct command' do
        if OS.windows?
          let(:cmd) { 'dir' }
          it { expect { subject}.to_not raise_error }
        elsif OS.osx?
          let(:cmd) { 'ls' }
          it { expect { subject}.to_not raise_error }
        elsif OS.linux?
          let(:cmd) { 'date' }
          it { expect { subject}.to_not raise_error }
        end
      end

      describe 'with incorrect command' do
        if OS.windows?
          let(:cmd) { 'ls' }
          it { expect { subject}.to raise_error }
        elsif OS.osx?
          let(:cmd) { 'dir' }
          it { expect { subject}.to raise_error }
        elsif OS.linux?
          let(:cmd) { '123' }
          it { expect { subject}.to raise_error }
        end
      end
  end

  describe '#last_execute_status' do

    before :each do
      instance.instance_variable_set(:@result, 'mocked result')
    end

    let(:instance) { described_class.new }
    subject { instance.last_execute_result }

    it { expect(subject).to eq('mocked result') }
  end

end
