require 'ostruct'
class Testing::Mock::MockedShellExecutor
  def initialize
    @commands = {}
    @last_exetuded_command = nil
  end
  def register_command(cmd, output, existstatus, success)
    result = OpenStruct.new(:exitstatus => existstatus, :success? => success)
    @last_exetuded_command = result
    @commands[cmd] = output
  end

  def run_command(cmd)
    raise ArgumentError, "Commmand #{cmd} has not been registered in mocked execution stack" unless @commands.include? cmd
    result = @commands[cmd]
    result[cmd]
  end

  def child_status
    @last_exetuded_command
  end
end
