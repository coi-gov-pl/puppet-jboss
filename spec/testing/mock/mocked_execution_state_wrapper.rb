require 'ostruct'

class Testing::Mock::ExecutionStateWrapper < PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper
  EMPTY_OUTPUT = {
    'outcome' => 'success',
    'result'  => {}
  }.inspect

  EMPTY_FAILURE_OUTPUT = {
    'outcome'             => 'failure',
    'failure-description' => 'some fatal error'
  }.inspect

  def initialize
    @commands = {}
    @shell = Testing::Mock::MockedShellExecutor.new
    super(@shell)
  end

  def execute(cmd, jbosscmd)
    raise ArgumentError, "Command #{jbosscmd.inspect} is not registered" if @commands[jbosscmd].nil?
    mockcmd = PuppetX::Coi::Jboss::Value::Command.new(
      @commands[jbosscmd], cmd.environment
    )
    super(mockcmd, jbosscmd)
  end

  def register_command(jbosscmd, output = EMPTY_OUTPUT, exitstatus = 0)
    cmd = "jboss-cli-mock run #{jbosscmd.inspect}"
    @commands[jbosscmd] = cmd
    @shell.register_command(cmd, repr(output), exitstatus)
  end

  def register_failing_command(jbosscmd, output = EMPTY_FAILURE_OUTPUT, exitstatus = 5)
    register_command(jbosscmd, output, exitstatus)
  end

  def verify_commands_executed
    @shell.verify_commands_executed
  end

  private

  def repr(output)
    output.is_a?(String) ? output : output.inspect
  end
end
