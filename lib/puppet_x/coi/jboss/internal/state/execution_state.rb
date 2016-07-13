# Wrapper that holds informations about result of command execution
class Puppet_X::Coi::Jboss::Internal::State::ExecutionState

  # Constructor that creates execution state object
  # @param {Int} ret_code return code of command execution
  # @param {Boolean} succes value that represents if command execution was succesfull
  # @param {String} output result of command execution
  # @param {String} command command that was executed
  def initialize(ret_code, success, output, command)
    @ret_code = ret_code
    @success = success
    @output = output
    @command = command
  end

  attr_reader :ret_code, :success, :output, :command

end
