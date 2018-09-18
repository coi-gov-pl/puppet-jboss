require 'spec_helper'

describe PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper do
  describe 'execute method' do
    let(:mocked_shell_executor) { Testing::Mock::MockedShellExecutor.new }

    let(:instance) { described_class.new(mocked_shell_executor) }
    let(:full_command) { PuppetX::Coi::Jboss::Value::Command.new(cmd, environment) }
    subject { instance.execute(full_command, jbosscmd) }

    describe 'destroy method' do
      before :each do
        mocked_shell_executor.register_command(
          '/profille=full-ha/subsystem=securitydomain:remove()',
          'asdads'
        )
      end
      let(:cmd) { '/profille=full-ha/subsystem=securitydomain:remove()' }
      let(:jbosscmd) { 'asd' }
      let(:environment) { { :password => 'password' } }
      it { expect(subject.success).to eq(true) }
    end

    describe 'read method' do
      before :each do
        mocked_shell_executor.register_command(
          '/profille=full-ha/subsystem=securitydomain:read-resource(recursive=true)',
          'result => succes, asdadass'
        )
      end
      let(:cmd) { '/profille=full-ha/subsystem=securitydomain:read-resource(recursive=true)' }
      let(:jbosscmd) { 'asd' }
      let(:environment) { { :password => 'password' } }
      it { expect(subject.success).to eq(true) }
    end
  end
end
