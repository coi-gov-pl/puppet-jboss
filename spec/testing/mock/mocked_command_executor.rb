require "spec_helper"
class Testing::Mock::MockedShellExecutor < Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor

  def initialize
    @commands = {}
    @last_excuted_command = nil
  end

  def register_command(command, expected_status, expected_lines)
    status = double('Mocked status', :success? => expected_status)
    outcome = { :status => status, :output => expected_lines, :executed => false }
    @commands[command] = outcome
  end

  def run_command(cmd)
    outcome = get_command_outcome(cmd)
    if outcome[:executed]
      raise ArgumentError, "Command #{cmd} should be executed only once"
    else
      outcome[:executed] = true
    end
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

  def verify_commands_executed
    @commands.each do | command ,outcome|
      raise ArgumentError, "Command #{command} was not executed but was expected" unless outcome[:executed]
    end
  end

  private
  def get_command_outcome(command)
    unless @commands.include? command
      raise ArgumentError, "Commmand #{command} has not been registered in mocked execution stack"
    end
    @commands[command]
  end
end
