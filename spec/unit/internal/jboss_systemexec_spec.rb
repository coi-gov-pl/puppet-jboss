require 'spec_helper'
require 'os'

describe Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor do
  describe 'with correct command' do
    let(:instance) { described_class.new }
    let(:execution) { instance.run_command(cmd) }
    let(:status) { instance.child_status }

    if OS.windows?
      let(:cmd) { 'dir' }
    elsif OS.osx?
      let(:cmd) { 'ls' }
    elsif OS.linux?
      let(:cmd) { 'ls' }
    end

    it { expect { execution }.to_not raise_error }
    it { expect(status).to be_truthy }
  end
end
