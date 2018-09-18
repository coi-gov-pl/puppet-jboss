require 'ostruct'

class Testing::Mock::ExecutionStateWrapper < PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper
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

  def register_command(jbosscmd, output = 'not important', exitstatus = 0)
    cmd = "jboss-cli-mock run #{jbosscmd.inspect}"
    @commands[jbosscmd] = cmd
    @shell.register_command(cmd, output.to_s, exitstatus)
  end

  def verify_commands_executed
    @shell.verify_commands_executed
  end
end
