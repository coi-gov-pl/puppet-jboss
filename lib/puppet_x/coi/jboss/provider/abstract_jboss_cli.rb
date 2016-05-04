# -*- coding: utf-8 -*-
require_relative '../configuration'
require 'tempfile'

# Base class for all JBoss providers
class Puppet_X::Coi::Jboss::Provider::AbstractJbossCli < Puppet::Provider

  # Default constructor that will also initialize 3 external object, system_runner, compilator and command executor
  def initialize(resource=nil)
    super(resource)
    @compilator = Puppet_X::Coi::Jboss::Internal::CommandCompilator.new

    system_command_executor = Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor.new
    system_runner = Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper.new(system_command_executor)
    @runner = Puppet_X::Coi::Jboss::Internal::CliExecutor.new(system_runner)
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

  def jbosslog
    Puppet_X::Coi::Jboss::Configuration::config_value :console_log
  end

  def config_runasdomain
    Puppet_X::Coi::Jboss::Configuration::config_value :runasdomain
  end

  def config_controller
    Puppet_X::Coi::Jboss::Configuration::config_value :controller
  end

  def config_profile
    Puppet_X::Coi::Jboss::Configuration::config_value :profile
  end


  # TODO: Uncomment for defered provider confinment after droping support for Puppet < 3.0
  # commands :jbosscli => Puppet_X::Coi::Jboss::Provider::AbstractJbossCli.jbossclibin

  def is_runasdomain
    @resource[:runasdomain]
  end

  def getlog(lines)
    last_lines = `tail -n #{lines} #{jbosslog}`
  end

  def printlog(lines)
    " ---\n JBoss AS log (last #{lines} lines): \n#{getlog lines}"
  end

  # Public methods
  def bringUp(typename, args)
    executeWithFail(typename, args, 'to create')
  end

  def bringDown(typename, args)
     executeWithFail(typename, args, 'to remove')
  end

  # INTERNAL METHODS
  # TODO make protected or private
  def execute jbosscmd
    retry_count = @resource[:retry]
    retry_timeout = @resource[:retry_timeout]
    ctrlcfg = controllerConfig @resource
    @runner.run_command(jbosscmd, is_runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  def executeWithoutRetry jbosscmd
    ctrlcfg = controllerConfig @resource
    @runner.run_command(jbosscmd, is_runasdomain, ctrlcfg, 0, 0)
  end

  def executeAndGet(jbosscmd)
    ctrlcfg = controllerConfig @resource
    executeAndGetResult(jbosscmd, is_runasdomain, ctrlcfg, 0, 0)
  end

  def executeWithFail(typename, passed_args, way)
    executed = execute(passed_args)
    if not executed[:result]
      ex = "\n#{typename} failed #{way}:\n[CLI command]: #{executed[:cmd]}\n[Error message]: #{executed[:lines]}"
      if not $add_log.nil? and $add_log > 0
        ex = "#{ex}\n#{printlog $add_log}"
      end
      raise ex
    end
    executed
  end

  def compilecmd cmd
    @compilator.compile(@resource[:runasdomain], @resource[:profile], cmd)
  end

  def executeAndGetResult(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    @runner.executeAndGet(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  # Method that will prepare and delegate execution of command
  def run_command(jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    @runner.run_command(jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
  end

  def controllerConfig resource
      conf = {
        :controller  => resource[:controller],
        :ctrluser    => resource[:ctrluser],
        :ctrlpasswd  => resource[:ctrlpasswd],
      }
      conf
  end

  def jboss_product
    @runner.jboss_product
  end

  def jbossas?
    @runner.jbossas?
  end

  def timeout_cli
    @runner.timeout_cli
  end

  def setattribute(path, name, value)
    escaped = value.nil? ? nil : escape(value)
    setattribute_raw(path, name, escaped)
  end

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

  $add_log = nil

  def isprintinglog=(setting)
    $add_log = setting
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
end
