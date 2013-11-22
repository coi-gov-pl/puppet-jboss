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

  def jbossclibin
    home = self.jbosshome
    path = "#{home}/#{@@bin}"
    return path
  end

  def jbosshome
    home=`grep -E '^JBOSS_HOME=' /etc/jboss-as/jboss-as.conf 2>/dev/null | cut -d '=' -f 2`
    home.strip!
    return home
  end
  
  def jbosslog
    log=`grep -E '^JBOSS_CONSOLE_LOG=' /etc/jboss-as/jboss-as.conf 2>/dev/null | cut -d '=' -f 2`
    log.strip!
    return log
  end

  #commands :jbosscli => jbossclibin
  
  def runasdomain?
    @resource[:runasdomain]
  end
  
  def getlog(lines)
    last_lines = `tail -n #{lines} #{jbosslog}`
  end
  
  def printlog(lines)
    return " ---\n JBoss AS log (last #{lines} lines): \n#{getlog lines}" 
  end

  def execute(jbosscmd)
    file = Tempfile.new('jbosscli')
    path = file.path
    file.close
    file.unlink

    File.open(path, 'w') {|f| f.write(jbosscmd + "\n") }

    ENV['JBOSS_HOME'] = self.jbosshome
    cmd = "#{self.jbossclibin} --connect --file=#{path}"
    if(resource[:runasdomain] == true )
      cmd = "#{cmd} --controller=#{resource[:controller]}"
    end

    Puppet.debug("JBOSS_HOME: " + self.jbosshome)
    Puppet.debug("Komenda do JBoss-cli: " + jbosscmd)
    lines = `#{cmd}`
    result = $?
    Puppet.debug("Output from jbosscli: " + lines)
    Puppet.debug("Result from jbosscli: " + result.inspect)
    # deletes the temp file
    File.unlink(path)
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
    res = execute_datasource(cmd)
    Puppet.debug(res.inspect)
    if not res[:result]
      raise "Cannot set #{name} for #{path}: #{res[:data]}"
    end
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
    Puppet.debug "TRACE > IN > #{method}"
  end
  
  def escape value
    if value.respond_to? :empty?
      str = '"%s"' % value.gsub(/([^\\])\"/, '\1\\"')
    else
      str = value.to_s
    end
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
    runasdomain = @resource[:runasdomain]
    out = cmd.to_s
    if runasdomain && out[0..9] == '/subsystem'
      out = "/profile=#{@resource[:profile]}#{out}"
    end
    return out
  end

  def execute_datasource passed_args
    ret = execute passed_args
    # Puppet.debug("exec ds result: " + ret.inspect)
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
    evalines = eval ret[:lines]
    Puppet.debug evalines.inspect
    return {
      :result  => evalines["outcome"] == "success",
      :data    => (evalines["outcome"] == "success" ? evalines["result"] : evalines["failure-description"])
    }
  end
end
