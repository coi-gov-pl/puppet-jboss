require 'spec_helper'
require 'os'

describe PuppetX::Coi::Jboss::Internal::Executor::ShellExecutor do
  describe 'with correct command' do
    let(:instance) { described_class.new }
    let(:execution) { instance.run_command(cmd) }
    let(:status) do
      execution
      instance.child_status
    end

    if OS.windows?
      let(:cmd) { 'dir' }
    elsif OS.osx?
      let(:cmd) { 'ls' }
    elsif OS.linux?
      let(:cmd) { 'ls' }
    end

    describe 'execution' do
      it { expect { execution }.to_not raise_error }
    end
    describe 'child process status' do
      it { expect(status).not_to be_nil }
      it { expect(status.success?).to be_truthy }
    end
  end
end
