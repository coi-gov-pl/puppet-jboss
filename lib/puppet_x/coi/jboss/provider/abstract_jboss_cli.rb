# -*- coding: utf-8 -*-
require_relative '../configuration'
require 'tempfile'

# Base class for all JBoss providers
class Puppet_X::Coi::Jboss::Provider::AbstractJbossCli < Puppet::Provider

  DEFAULT_SHELL_EXECUTOR = Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor.new

  # Default constructor that will also initialize 3 external object, system_runner, compilator and command executor
  # @param {Puppet::Resource} resource, standard Puppet resource that we need to call super
  def initialize(resource=nil)
    super(resource)
    @compilator = Puppet_X::Coi::Jboss::Internal::CommandCompilator.new
    @cli_executor = nil
    ensure_cli_executor
  end

  @@bin = "bin/jboss-cli.sh"
  @@contents = nil

  # Method that returns jboss-cli command path
  # @return {String} jboss-cli command path
  def jbossclibin
    home = self.jbosshome
    path = "#{home}/#{@@bin}"
    path
  end

  # CONFIGURATION VALUES

  # Method that returns jboss home value
  # @return {String} home value
  def jbosshome
    Puppet_X::Coi::Jboss::Configuration::config_value :home
  end

  # Method that returns value of log
  # @return {String} value of configuration for console log
  def jbosslog
    Puppet_X::Coi::Jboss::Configuration::config_value :console_log
  end

  # Method that returns value that teels us if we need to run jboss in domain
  # @return {Boolean} runasdomain indicates if we want to run jboss in domain mode
  def config_runasdomain
    Puppet_X::Coi::Jboss::Configuration::config_value :runasdomain
  end

  # Method that returns name of the controller that we will use when connecting to jboss instance
  # @return {String} controller
  def config_controller
    Puppet_X::Coi::Jboss::Configuration::config_value :controller
  end

  # Method that return name of the profile that we need to add at the start of jboss command
  # @return {String} profile
  def config_profile
    Puppet_X::Coi::Jboss::Configuration::config_value :profile
  end

  # TODO: Uncomment for defered provider confinment after droping support for Puppet < 3.0
  # commands :jbosscli => Puppet_X::Coi::Jboss::Provider::AbstractJbossCli.jbossclibin

  # Method that tells us if we want to run jboss in domain mode
  # @return {Boolean}
  def is_runasdomain
    @resource[:runasdomain]
  end

  # Method that delegates execution of command
  # @param {String} typename is a name of resource
  # @param {String} cmd command that will be executed
  def bringUp(typename, cmd)
    executeWithFail(typename, cmd, 'to create')
  end

  # Method that delegates execution of command
  # @param {String} typename is a name of resource
  # @param {String} cmd jboss command that will be executed
  def bringDown(typename, cmd)
     executeWithFail(typename, cmd, 'to remove')
  end

  # Method that configures every variable that is needed to execute the provided command
  # @param {String} jbosscmd jboss command that will be executed
  def execute(jbosscmd)
    retry_count = @resource[:retry]
    retry_timeout = @resource[:retry_timeout]
    ctrlcfg = controllerConfig @resource
    @cli_executor.run_command(jbosscmd, is_runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  # Method that executes command without any retry if command fails
  # @param {String} jbosscmd jboss command
  def executeWithoutRetry(jbosscmd)
    ctrlcfg = controllerConfig @resource
    @cli_executor.run_command(jbosscmd, is_runasdomain, ctrlcfg, 0, 0)
  end

  # Method that executes command without any retry if command fails
  # @param {String} jbosscmd jboss command
  def executeAndGet(jbosscmd)
    ctrlcfg = controllerConfig @resource
    executeAndGetResult(jbosscmd, is_runasdomain, ctrlcfg, 0, 0)
  end

  # Method that executes command and if command fails it prints information
  # @param {String} typename name of resource
  # @param {String} cmd jboss command
  # @param {String} way name of the action
  def executeWithFail(typename, cmd, way)
    executed = execute(cmd)
    if not executed[:result]
      ex = "\n#{typename} failed #{way}:\n[CLI command]: #{executed[:cmd]}\n[Error message]: #{executed[:lines]}"
      if not $add_log.nil? and $add_log > 0
        ex = "#{ex}\n#{printlog $add_log}"
      end
      raise ex
    end
    executed
  end

  # Method that delegates compilation of jboss command
  # @param {String} jboss command
  # @return {String} compiled jboss command
  def compilecmd(cmd)
    @compilator.compile(@resource[:runasdomain], @resource[:profile], cmd)
  end

  # Method that delegates execution of command to cli_executor
  # @param {String} cmd is a jboss command
  # @param {Boolean} runasdomain if we want to run jboss in domain mode
  # @param {Hash} ctrlcfg configuration hash
  # @param {Integer} retry_count is a number of times we want to retry execution of command after failure
  # @param {Integer} retry_timeout timmeout after which we assume that command failed to execute
  def executeAndGetResult(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    @cli_executor.executeAndGet(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  # Method that will prepare and delegate execution of command
  def run_command(jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    @cli_executor.run_command(jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  # Method that make configuration hash from resource
  # @param {Hash} resource standard Puppet resource
  # @return {Hash} conf hash that contains information that are need to execute command
  def controllerConfig resource
    conf = {
      :controller  => resource[:controller],
      :ctrluser    => resource[:ctrluser],
      :ctrlpasswd  => resource[:ctrlpasswd],
    }
    conf
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
    if value.nil?
      cmd = "#{path}:undefine-attribute(name=\"#{name.to_s}\")"
    else
      cmd = "#{path}:write-attribute(name=\"#{name.to_s}\", value=#{value})"
    end
    if is_runasdomain
      cmd = "/profile=#{@resource[:profile]}#{cmd}"
    end
    res = executeAndGet(cmd)
    Puppet.debug("Setting attribute response: #{res.inspect}")
    if not res[:result]
      raise "Cannot set #{name} for #{path}: #{res[:data]}"
    end
    @property_hash[name] = value
  end

  def trace method
    Puppet.debug '%s[%s] > IN > %s' % [self.class, @resource[:name], method]
  end

  def traceout method, retval
    Puppet.debug '%s[%s] > OUT > %s: %s' % [self.class, @resource[:name], method, retval.inspect]
  end

  def escape value
    if value.respond_to? :to_str
      str = value.gsub(/([^\\])\"/, '\1\\"')
    else
      str = value
    end
    str.inspect
  end

  # Standard setter for shell_executor
  # @param {Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor} shell_executor
  def shell_executor=(shell_executor)
    @cli_executor.shell_executor = shell_executor
  end

  # Standard getter for shell executor
  def shell_executor
    @cli_executor.shell_executor
  end

  # Standard setter for execution state wrapper
  # @param {Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper} execution_state_wrapper
  def execution_state_wrapper=(execution_state_wrapper)
    @cli_executor.execution_state_wrapper = execution_state_wrapper
  end

  protected

  def ensure_cli_executor
    if @cli_executor.nil?
      execution_state_wrapper = Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper.new(DEFAULT_SHELL_EXECUTOR)
      @cli_executor = Puppet_X::Coi::Jboss::Internal::CliExecutor.new(execution_state_wrapper)
    end
    @cli_executor
  end
end
