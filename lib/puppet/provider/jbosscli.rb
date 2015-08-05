# -*- coding: utf-8 -*-
require 'tempfile'

class Object
  def blank?
    return true if self.nil?
    self.respond_to?(:empty?) ? self.empty? : !self
  end
  
  def to_bool
    if self.respond_to?(:empty?)
      str = self
    else
      str = self.to_s
    end
    if self.is_a? Numeric
      return self != 0
    end
    return true if self == true || str =~ (/(true|t|yes|y)$/i)
    return false if self == false || self.blank? || str =~ (/(false|f|no|n)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end
class Hash
  def hashbackmap
    result = {}
  
    self.each do |key, val|
      result[key] = yield val
    end
  
    result
  end
end
module Coi
  module Puppet
    module Functions
      def self.to_bool input
        input.to_bool
      end
      
      def self.basename file
        File.basename file
      end 
    end
  end
end

class Puppet::Provider::Jbosscli < Puppet::Provider

  @@bin = "bin/jboss-cli.sh"
  @@contents = nil

  def self.jbossclibin
    home = self.jbosshome
    path = "#{home}/#{@@bin}"
    return path
  end

  def self.jbosshome
    Facter.value :jboss_home
  end
  
  def self.jbosslog
    Facter.value :jboss_console_log
  end
  
  def self.config_runasdomain
    ret = Facter.value :jboss_runasdomain
    ret.to_bool
  end

  def self.config_controller
    Facter.value :jboss_controller
  end

  def self.config_profile
    Facter.value :jboss_profile
  end
  
  # commands :jbosscli => Puppet::Provider::Jbosscli.jbossclibin
  
  def runasdomain?
    @resource[:runasdomain]
  end
  
  def getlog(lines)
    last_lines = `tail -n #{lines} #{jbosslog}`
  end
  
  def printlog(lines)
    return " ---\n JBoss AS log (last #{lines} lines): \n#{getlog lines}" 
  end

  def execute jbosscmd
    retry_count = @resource[:retry]
    retry_timeout = @resource[:retry_timeout]
    ctrlcfg = Puppet::Provider::Jbosscli.controllerConfig @resource
    return Puppet::Provider::Jbosscli.execute jbosscmd, runasdomain?, ctrlcfg, retry_count, retry_timeout
  end

  def executeWithoutRetry jbosscmd
    ctrlcfg = Puppet::Provider::Jbosscli.controllerConfig @resource
    return Puppet::Provider::Jbosscli.execute jbosscmd, runasdomain?, ctrlcfg, 0, 0
  end

  def executeAndGet jbosscmd
    ctrlcfg = Puppet::Provider::Jbosscli.controllerConfig @resource
    return Puppet::Provider::Jbosscli.executeAndGet jbosscmd, runasdomain?, ctrlcfg, 0, 0
  end

  def self.controllerConfig resource
      conf = {
        :controller  => resource[:controller],
        :ctrluser    => resource[:ctrluser],
        :ctrlpasswd  => resource[:ctrlpasswd],
      }
      return conf
  end
  
  def self.last_execute_status
    $?
  end
  
  def self.jbossas?
    Facter.value(:jboss_product) == 'jboss-as'
  end
  
  def self.timeout_cli
    '--timeout=50000' unless jbossas?
  end

  def self.execute jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout
    file = Tempfile.new 'jbosscli'
    path = file.path
    file.close
    file.unlink

    File.open(path, 'w') {|f| f.write(jbosscmd + "\n") }

    ENV['JBOSS_HOME'] = self.jbosshome
    cmd = "#{self.jbossclibin} #{timeout_cli} --connect --file=#{path} --controller=#{ctrlcfg[:controller]}"
    unless ctrlcfg[:ctrluser].nil?
      cmd += " --user=#{ctrlcfg[:ctrluser]}"
    end
    unless ctrlcfg[:ctrlpasswd].nil?
      ENV['__PASSWD'] = ctrlcfg[:ctrlpasswd]
      cmd += " --password=$__PASSWD"
    end
	
    retries = 0
    result = ''
    lines = ''
    begin
      if retries > 0 
        Puppet.warning "JBoss CLI command failed, try #{retries}/#{retry_count}, last status: #{result.exitstatus.to_s}, message: #{lines}"
        sleep retry_timeout.to_i
      end
      Puppet.debug "Command send to JBoss CLI: " + jbosscmd
      lines = Puppet::Util::Execution.execute(cmd, options = {
        :failonfail => false,
        :combine    => true,
      })
      result = self.last_execute_status
      retries += 1
    end while (result.exitstatus != 0 && retries <= retry_count)
    Puppet.debug "Output from JBoss CLI [%s]: %s" % [result.inspect, lines]
    # deletes the temp file
    File.unlink path
    return {
      :cmd    => jbosscmd,
      :result => result.exitstatus == 0,
      :lines  => lines
    }
  end
  
  def setattribute(path, name, value)
    setattribute_raw path, name, escape(value)
  end
  
  def setattribute_raw(path, name, value)
    Puppet.debug "#{name.inspect} setting to #{value.inspect} for path: #{path}"
    cmd = "#{path}:write-attribute(name=\"#{name.to_s}\", value=#{value})"
    if runasdomain?
      cmd = "/profile=#{@resource[:profile]}#{cmd}"
    end
    res = executeAndGet(cmd)
    Puppet.debug(res.inspect)
    if not res[:result]
      raise "Cannot set #{name} for #{path}: #{res[:data]}"
    end
    @property_hash[name] = value
  end
  
  def bringUp(typename, args)
    return executeWithFail(typename, args, 'to create')
  end
  
  def bringDown(typename, args)
    return executeWithFail(typename, args, 'to remove')
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
  
  def self.escape value
    if value.respond_to? :to_str
      str = value.gsub(/([^\\])\"/, '\1\\"')
    else
      str = value
    end
    return str.inspect
  end
  
  def escape value
    Puppet::Provider::Jbosscli.escape value
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
    return executed
  end
  
  def compilecmd cmd
    Puppet::Provider::Jbosscli.compilecmd @resource[:runasdomain], @resource[:profile], cmd
  end
  
  def self.compilecmd runasdomain, profile, cmd
    out = cmd.to_s
    asdomain = runasdomain.to_bool
    if asdomain && out[0..9] == '/subsystem'
      out = "/profile=#{profile}#{out}"
    end
    return out
  end

  def self.executeAndGet cmd, runasdomain, ctrlcfg, retry_count, retry_timeout
    ret = self.execute cmd, runasdomain, ctrlcfg, retry_count, retry_timeout
    if not ret[:result]
        return {
          :result => false,
          :data => ret[:lines]
        }
    end
    # Wskazanie typu dla undefined
    undefined = nil
    # Obsługa expression z JBossa
    ret[:lines].gsub!(/expression \"(.+)\",/, '\'\1\',')
    ret[:lines].gsub!(/=> (\d+)L/, '=> \1')
    begin
      evalines = eval ret[:lines]
      Puppet.debug evalines.inspect
      return {
        :result  => evalines["outcome"] == "success",
        :data    => (evalines["outcome"] == "success" ? evalines["result"] : evalines["failure-description"])
      }
    rescue Exception => e
      Puppet.err e
      return {
        :result  => false,
        :data    => ret[:lines]
      }
    end
  end

end
