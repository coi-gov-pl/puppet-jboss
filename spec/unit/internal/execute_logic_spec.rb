require 'spec_helper_puppet'

describe PuppetX::Coi::Jboss::Internal::ExecuteLogic do
  let(:instance) { described_class.new }
  let(:mock_values) do
    { :console_log => 'spec/testing/files/example.log' }
  end
  before(:each) { instance.lines_to_display = 2 }
  before(:each) { PuppetX::Coi::Jboss::Configuration.reset_config(mock_values) }
  after(:each) { PuppetX::Coi::Jboss::Configuration.reset_config }

  let(:typename) { 'Resource' }
  let(:cmd) { '/qwerty:add()' }
  let(:way) { 'up' }
  let(:executor) do
    proc do |cmd|
      PuppetX::Coi::Jboss::Internal::State::ExecutionState.new(
        retcode,
        retcode == 0,
        'not important',
        cmd
      )
    end
  end

  describe '#execute_with_fail' do
    subject { instance.execute_with_fail(typename, cmd, way, executor) }

    describe 'failing command' do
      let(:retcode) { 3 }

      it do
        expect { subject }.to raise_error(
          Puppet::Error,
          "\n" \
          "Resource failed up:\n" \
          "[CLI command]: /qwerty:add()\n" \
          "[Error message]: not important\n" \
          " ---\n" \
          "JBoss log (last 2 lines): \n" \
          "17:52:00,914 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0051: Admin console listening on http://0.0.0.0:9990\n" \
          "17:52:00,915 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0025: WildFly Full 9.0.2.Final (WildFly Core 1.0.2.Final) started in 5313ms - Started 323 of 502 services (233 services are lazy, passive or on-demand)\n"
        )
      end
    end
  end
end
