class Puppet_X::Coi::Jboss::Internal::ExecutionState

  def initialize(ret_code, success, output, command)
    @ret_code = ret_code
    @success = success
    @output = output
    @command = command
  end

  attr_reader :ret_code, :success, :output, :command

end
