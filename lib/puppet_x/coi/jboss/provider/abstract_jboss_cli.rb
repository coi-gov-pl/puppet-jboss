# -*- coding: utf-8 -*-
require_relative '../configuration'
require 'tempfile'

# Base class for all JBoss providers
class PuppetX::Coi::Jboss::Provider::AbstractJbossCli < Puppet::Provider
  include PuppetX::Coi::Jboss::Checks
  DEFAULT_SHELL_EXECUTOR = PuppetX::Coi::Jboss::Internal::Executor::ShellExecutor.new

  # Default constructor that will also initialize 3 external object, system_runner, compilator and command executor
  # @param resource [Puppet::Resource] standard Puppet resource that we need to call super
  def initialize(resource = nil)
    super(resource)
    @compilator   = PuppetX::Coi::Jboss::Internal::CommandCompilator.new
    @execlogic    = PuppetX::Coi::Jboss::Internal::ExecuteLogic.new
    @cli_executor = nil
    ensure_cli_executor
  end

  # TODO: Uncomment for defered provider confinment after droping support for Puppet < 3.0
  # commands :jbosscli => PuppetX::Coi::Jboss::Provider::AbstractJbossCli.jbossclibin

  # Method that tells us if we want to run jboss in domain mode
  # @return [Boolean] do run at domain mode?
  def runasdomain?
    @resource[:runasdomain]
  end

  # Method that delegates execution of command
  # @param typename [String] is a name of resource
  # @param cmd [String] command that will be executed
  def bring_up(typename, cmd)
    execute_with_fail(typename, cmd, 'to create')
  end

  # Method that delegates execution of command
  # @param typename [String] is a name of resource
  # @param cmd [String] jboss command that will be executed
  def bring_down(typename, cmd)
    execute_with_fail(typename, cmd, 'to remove')
  end

  # Method that configures every variable that is needed to execute the provided command
  # @param jbosscmd [String] jboss command that will be executed
  def execute(jbosscmd)
    ctrlcfg = controller_config @resource
    try = PuppetX::Coi::Jboss::Value::Try.new(@resource[:retry], @resource[:retry_timeout])
    @cli_executor.run_jboss_command(jbosscmd, runasdomain?, ctrlcfg, try)
  end

  # Method that executes command without any retry if command fails
  # @param jbosscmd [String] jboss command
  def execute_without_retry(jbosscmd)
    ctrlcfg = controller_config @resource
    try = PuppetX::Coi::Jboss::Value::Try::ZERO
    @cli_executor.execute_and_get(jbosscmd, runasdomain?, ctrlcfg, try)
  end

  # Method that executes command without any retry if command fails
  # @param jbosscmd [String] jboss command
  def execute_and_get(jbosscmd)
    ctrlcfg = controller_config @resource
    execute_and_get_result(
      jbosscmd, runasdomain?, ctrlcfg, PuppetX::Coi::Jboss::Value::Try::ZERO
    )
  end

  # Method that executes command and if command fails it prints information
  # @param typename [String] name of resource
  # @param cmd [String] jboss command
  # @param way [String] name of the action
  def execute_with_fail(typename, cmd, way)
    executor = proc { |compiled| execute(compiled) }
    @execlogic.execute_with_fail(typename, cmd, way, executor)
  end

  # Method that delegates compilation of jboss command
  # @param jboss [String] command
  # @return [String]      compiled jboss command
  def compilecmd(cmd)
    @compilator.compile(@resource[:runasdomain], @resource[:profile], cmd)
  end

  # Method that delegates execution of command to cli_executor
  # @param cmd         [String]  is a jboss command
  # @param runasdomain [Boolean] if we want to run jboss in domain mode
  # @param ctrlcfg     [Hash]    configuration hash
  # @param try [PuppetX::Coi::Jboss::Value::Try] the try object
  def execute_and_get_result(cmd, runasdomain, ctrlcfg, try)
    @cli_executor.execute_and_get(cmd, runasdomain, ctrlcfg, try)
  end

  # Method that will prepare and delegate execution of command
  def run_jboss_command(jbosscmd, runasdomain, ctrlcfg, try)
    @cli_executor.run_jboss_command(jbosscmd, runasdomain, ctrlcfg, try)
  end

  # Method that make configuration hash from resource
  # @param resource [Hash] standard Puppet resource
  # @return {Hash} conf hash that contains information that are need to execute command
  def controller_config(resource)
    {
      :controller => resource[:controller],
      :ctrluser   => resource[:ctrluser],
      :ctrlpasswd => resource[:ctrlpasswd]
    }
  end

  # Standard getter for jboss_product
  # @return {String} jboss_product
  def jboss_product
    @cli_executor.jboss_product
  end

  # Standard getter for jbossas
  # @return {String} jbossas
  def jbossas?
    @cli_executor.jbossas?
  end

  # Standard getter for timeout_cli
  def timeout_cli
    @cli_executor.timeout_cli
  end

  def setattribute(path, name, value)
    escaped = value.nil? ? nil : escape(value)
    setattribute_raw(path, name, escaped)
  end

  # Low level set attribute method that sets value to property hash
  #
  # @return {Object} actually set value
  def setattribute_raw(path, name, value)
    Puppet.debug "#{name.inspect} setting to #{value.inspect} for path: #{path}"
    cmd = if value.nil?
            "#{path}:undefine-attribute(name=\"#{name}\")"
          else
            "#{path}:write-attribute(name=\"#{name}\", value=#{value})"
          end
    cmd = "/profile=#{@resource[:profile]}#{cmd}" if runasdomain?
    res = execute_and_get(cmd)
    Puppet.debug("Setting attribute response: #{res.inspect}")
    raise "Cannot set #{name} for #{path}: #{res[:data]}" unless res[:result]
    @property_hash[name] = value
  end

  def trace(method)
    Puppet.debug format(
      '%s[%s] > IN > %s', self.class, @resource[:name], method
    )
  end

  def traceout(method, retval)
    Puppet.debug format(
      '%s[%s] > OUT > %s: %s',
      self.class, @resource[:name], method, retval.inspect
    )
  end

  def escape(value)
    str = if value.respond_to? :to_str
            value.gsub(/([^\\])\"/, '\1\\"')
          else
            value
          end
    str.inspect
  end

  # Standard setter for execution state wrapper
  # @param executor [PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper]
  def executor(executor)
    @cli_executor.executor = executor
  end

  # Setter for lines_to_display
  def display_lines(lines_to_display)
    @execlogic.lines_to_display = lines_to_display
  end

  protected

  # Method that ensures that there is cli executor, if not it will create default one
  # @return {PuppetX::Coi::Jboss::Internal::CliExecutor} cli_executor
  def ensure_cli_executor
    if @cli_executor.nil?
      wrapper = PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper.new(
        DEFAULT_SHELL_EXECUTOR
      )
      @cli_executor = PuppetX::Coi::Jboss::Internal::CliExecutor.new(
        wrapper, @execlogic
      )
    end
    @cli_executor
  end
end
