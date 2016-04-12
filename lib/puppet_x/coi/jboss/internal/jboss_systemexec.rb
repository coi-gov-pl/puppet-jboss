# System executor responsible of executing provided commands
class Puppet_X::Coi::Jboss::Internal::JbossSystemExec

  # Method that handles delegation to system executor
  # @param {String} cmd cmd to be executed
  # @param {String} jbosscmd to be executed
  # @param {Hash} environment hash that hold informations about configuration
  # @return {Puppet_X::Coi::Jboss::Internal::ExecutionState} execution state that hold
  #         information about result of execution
  def execute(cmd, jbosscmd, environment)
    lines = exec_command(cmd, environment)
    result = last_execute_result

    code = result.exitstatus
    success = result.success?

    Puppet.debug 'execution state begins'

    exececution_state(jbosscmd, code, success, lines)
  end

  # Runs prepared commands
  # @param {String} cmd command that will be executed
  # @param {Hash} environment hash with proccess environment
  # @return {String} output of executed command
  # The location of withenv changed from Puppet 2.x to 3.x
  def exec_command(cmd, environment)

    withenv = Puppet::Util.method(:withenv) if Puppet::Util.respond_to?(:withenv)
    withenv = Puppet::Util::Execution.method(:withenv) if Puppet::Util::Execution.respond_to?(:withenv)
    fail("Cannot set custom environment #{environment}") if environment && !withenv

    withenv.call environment do
          @output = run_command(cmd)
          @result = child_status
        end
    @output
  end

  # Method that returns status of last command executed
  # @return {Process::Status} result of last command
  def last_execute_result
    @result
  end

  def exececution_state(jbosscmd, code, success, lines)
    Puppet_X::Coi::Jboss::Internal::ExecutionState.new(code, success, lines, jbosscmd)
  end

  def run_command(cmd)
    `#{cmd}`
  end

  def child_status
    $?
  end
end
