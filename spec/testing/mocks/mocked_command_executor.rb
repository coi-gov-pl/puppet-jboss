require "spec_helper"
class Testing::Mock::MockedCommandExecutor < Puppet_X::Coi::Jboss::Internal::JbossCommandExecutor

  def initialize
    @commands = {}
    @last_excuted_command = nil
  end

  def register_command(command, expected_status, expected_lines)
    status = double('Mocked status', :success? => expected_status)
    outcome = {:status => status, :output => expected_lines}
    commands[command] = outcome
  end

  def run_command(cmd)
    outcome = get_command_outcome(cmd)
    @last_excuted_command = cmd
    outcome[:output]
  end

  #  Method to check return code from last command that was executed
  # @return {Process::Status} result of last command
  def child_status
    raise ArgumentError, 'Last executed command is nil' if @last_excuted_command.nil?
    outcome = get_command_outcome(@last_excuted_command)
    outcome[:status]
  end

  private
  def get_command_outcome(command)
    unless @commands.include? command
      raise ArgumentError, "Commmand #{command} has not been registered in mocked execution stack"
    end
    @commands[command]
  end
end
