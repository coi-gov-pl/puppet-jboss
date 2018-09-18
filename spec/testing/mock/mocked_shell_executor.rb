require 'ostruct'
require 'json'

class Testing::Mock::MockedShellExecutor < PuppetX::Coi::Jboss::Internal::Executor::ShellExecutor
  def initialize
    @commands = {}
    @executions = {}
    @last_exetuded_command = nil
  end

  def register_command(cmd, output, exitstatus = 0, success = nil)
    success = exitstatus == 0 if success.nil?
    status = OpenStruct.new(
      :exitstatus => exitstatus,
      :success?   => success
    )
    result = {
      :output => output,
      :status => status
    }
    @commands[cmd] = [] if @commands[cmd].nil?
    @commands[cmd].push(result)
    result
  end

  def verify_commands_executed
    @commands.each do |command, results|
      raise ArgumentError, "Command #{command.inspect} was not executed but was expected" unless results.empty?
    end
  end

  def run_command(cmd)
    raise ArgumentError, "Command #{cmd.inspect} hasn't been registered in mocked shell executor" unless @commands.include? cmd
    executions = @commands[cmd]
    if executions.empty?
      previous = JSON.pretty_generate(@executions[cmd])
      raise ArgumentError, "Command #{cmd.inspect} exceeded execution limit. Executions: #{previous}"
    end
    result = executions.shift
    @executions[cmd] ||= []
    @executions[cmd].push(caller)
    @last_exetuded_command = result[:status]
    result[:output]
  end

  def child_status
    @last_exetuded_command
  end
end
