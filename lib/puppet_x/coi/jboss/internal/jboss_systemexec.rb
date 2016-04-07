# System executor responsible of executing provided commands
class Puppet_X::Coi::Jboss::Internal::JbossSystemExec

  # Runs prepared commands
  # @param {String} cmd command that will be executed
  # @return {String} output of executed command
  def exec_command(cmd)
    @output = `#{cmd}`
    @result = $?
    @output
  end

  # Method that returns status of last command executed
  # @return {Process::Status} result of last command
  def last_execute_result
    @result
  end
end
