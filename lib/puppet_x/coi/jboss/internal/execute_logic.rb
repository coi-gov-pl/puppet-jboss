# Class that perform logic of execution of commands
class PuppetX::Coi::Jboss::Internal::ExecuteLogic
  include PuppetX::Coi::Jboss::Checks

  def initialize
    @lines_to_display = 0
  end

  # Method that executes command and if command fails it prints information
  #
  # @param {String}   typename name of resource
  # @param {String}   cmd      jboss command
  # @param {String}   way      name of the action
  # @param {Callable} executor an executor of command
  def execute_with_fail(typename, cmd, way, executor)
    state = executor.call(cmd)
    unless state.success?
      ex = "\n#{typename} failed #{way}:\n[CLI command]: #{state.command}\n[Error message]: #{state.output}"
      raise Puppet::Error, add_log_if_any(ex)
    end
    state
  end

  # Setter for lines_to_display
  def lines_to_display=(lines_to_display)
    @lines_to_display = lines_to_display + 0
  end

  private

  # Method that returns value of log
  # @return {String} value of configuration for console log
  def jbosslog
    assert_not_nil PuppetX::Coi::Jboss::Configuration.config_value(:console_log)
  end

  def add_log_if_any(ex)
    ex = "#{ex}\n#{printlog @lines_to_display}" if @lines_to_display > 0
    ex
  end

  def printlog(lines)
    " ---\nJBoss log (last #{lines} lines): \n#{getlog lines}"
  end

  def getlog(lines)
    tail = PuppetX::Coi::Jboss::Tail.new(File.new(jbosslog))
    tail.get(lines)
  end
end
