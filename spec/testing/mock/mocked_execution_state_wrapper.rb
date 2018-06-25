require 'spec_helper'
require 'ostruct'

class Testing::Mock::ExecutionStateWrapper < Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper
  def initialize
    @commands = {}
    @last_excuted_command = nil
  end

  def register_command(command, expected_status, expected_lines, expected_result)
    execution_state = Puppet_X::Coi::Jboss::Internal::State::ExecutionState.new(
      expected_result,
      expected_status,
      expected_lines,
      command
    )
    @commands[command] = execution_state
  end

  def execute(_cmd, jbosscmd, _environment)
    get_command_outcome(jbosscmd)
    @last_excuted_command = jbosscmd
    @commands[jbosscmd]
  end

  def verify_commands_executed
    @commands.each do |command, outcome|
      raise ArgumentError, "Command #{command} was not executed but was expected" unless outcome[:executed]
    end
  end

  private

  def get_command_outcome(command)
    raise ArgumentError, "Commmand #{command} has not been registered in mocked execution stack" unless @commands.include? command
  end
end
