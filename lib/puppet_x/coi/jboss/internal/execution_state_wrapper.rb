# System executor responsible of executing provided commands
class Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper
  def initialize(shell_executor)
    @shell_executor = shell_executor
  end

  attr_accessor :shell_executor

  # Method that handles delegation to system executor
  # @param {String} cmd cmd to be executed
  # @param {String} jbosscmd to be executed
  # @param {Hash} environment hash that hold informations about configuration
  # @return {Puppet_X::Coi::Jboss::Internal::ExecutionState} execution state that hold
  # information about result of execution
  def execute(cmd, jbosscmd, environment)
    lines = exec_command(cmd, environment)
    result = last_execute_result

    code = result.exitstatus
    success = result.success?

    Puppet.debug 'execution state begins'

    exececution_state(jbosscmd, code, success, lines)
  end

  # Method that returns status of last command executed
  # @return {Process::Status} result of last command
  def last_execute_result
    @result
  end

  private

  # Runs prepared commands
  # @param {String} cmd command that will be executed
  # @param {Hash} environment hash with proccess environment
  # @return {String} output of executed command
  # The location of withenv changed from Puppet 2.x to 3.x
  def exec_command(cmd, environment)
    withenv = Puppet::Util.method(:withenv) if Puppet::Util.respond_to?(:withenv)
    withenv = Puppet::Util::Execution.method(:withenv) if Puppet::Util::Execution.respond_to?(:withenv)
    raise("Cannot set custom environment #{environment}") if environment && !withenv

    withenv.call environment do
      @output = @shell_executor.run_command(cmd)
      @result = @shell_executor.child_status
    end
    @output
  end

  # Method that make and execution state object with given parameters
  # @return {Puppet_X::Coi::Jboss::Internal::ExecutionState} execution state that contains informations about result of command execution
  def exececution_state(jbosscmd, code, success, lines)
    Puppet_X::Coi::Jboss::Internal::State::ExecutionState.new(code, success, lines, jbosscmd)
  end
end
