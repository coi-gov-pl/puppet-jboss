# Wrapper that holds informations about result of command execution
class PuppetX::Coi::Jboss::Internal::State::ExecutionState
  # Constructor that creates execution state object
  # @param retcode [Int]    return code of command execution
  # @param succes [Boolean] value that represents if command execution was succesfull
  # @param output [String]  result of command execution
  # @param command [String] command that was executed
  def initialize(retcode, success, output, command)
    @retcode = retcode
    @success = success
    @output = output
    @command = command
  end

  # Standard getters for retcode, success, output and command
  attr_reader :retcode, :success, :output, :command

  def success?
    success
  end
end
