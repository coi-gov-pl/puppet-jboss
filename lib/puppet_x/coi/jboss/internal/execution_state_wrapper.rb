# System executor responsible of executing provided commands
class PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper
  # Standard constructor
  # @param shell_executor [PuppetX::Coi::Jboss::Internal::Executor::ShellExecutor]
  def initialize(shell_executor)
    @shell_executor = shell_executor
  end

  # Standard setter for shell_executor
  attr_accessor :shell_executor

  # Method that handles delegation to system executor
  # @param cmd [PuppetX::Coi::Jboss::Value::Command] command to be executed
  # @param jbosscmd [String] to be executed
  # @param environment [Hash] hash that hold informations about configuration
  # @return [PuppetX::Coi::Jboss::Internal::ExecutionState] execution state that hold information about result of execution
  def execute(cmd, jbosscmd)
    lines = exec_command(cmd)
    result = last_execute_result
    code = result.exitstatus
    success = result.success?

    PuppetX::Coi::Jboss::Internal::State::ExecutionState.new(
      code,
      success,
      lines,
      jbosscmd
    )
  end

  # Method that returns status of last command executed
  # @return {Process::Status} result of last command
  def last_execute_result
    @result
  end

  private

  # Runs prepared commands
  # @param cmd [PuppetX::Coi::Jboss::Value::Command] command that will be executed
  # @return {String} output of executed command
  def exec_command(cmd)
    environment = cmd.environment
    # The location of withenv changed from Puppet 2.x to 3.x
    withenv = Puppet::Util.method(:withenv) if Puppet::Util.respond_to?(:withenv)
    withenv = Puppet::Util::Execution.method(:withenv) if Puppet::Util::Execution.respond_to?(:withenv)
    raise("Cannot set custom environment #{environment}") if environment && !withenv

    withenv.call environment do
      @output = @shell_executor.run_command(cmd.command)
      @result = @shell_executor.child_status
    end
    @output
  end
end
