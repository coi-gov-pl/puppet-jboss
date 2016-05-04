# Class that handles shell command execution
class Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor

  # Method that executes method by real system command execution
  # @param {String} cmd command that will be executed
  def run_command(cmd)
    `#{cmd}`
  end

  #  Method to check return code from last command that was executed
  # @return {Process::Status} result of last command
  def child_status
    $?
  end
end
