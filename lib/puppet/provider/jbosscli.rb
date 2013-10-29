require 'tempfile'

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
    Puppet.debug(name.inspect + ' setting to ' + value.inspect)
    val = value.to_s
    if value.is_a? String
      val = "\"#{val}\""
    end
    cmd = "#{path}:write-attribute(name=\"#{name.to_s}\", value=#{val})"
    runasdomain = @resource[:runasdomain]
    if runasdomain
      cmd = "/profile=#{@resource[:profile]}#{cmd}"
    end
    res = execute_datasource(cmd)
    Puppet.debug(res.inspect)
    if not res[:result]
      raise "Cannot set #{name}: #{res[:data]}"
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
    if runasdomain
      out = "/profile=#{@resource[:profile]}#{out}"
    end
    return out
  end

  def execute_datasource(passed_args)
    ret = execute(passed_args)
    #Puppet.debug("exec ds result: " + ret.inspect)
    if ret[:result] == false
        return {
          :result => false,
          :data => ret[:lines]
        }
    end
    #wskazanie typu dla undefined
    undefined = nil
    evalines = eval(ret[:lines])
    Puppet.debug(evalines.inspect)
    return {
      :result  => evalines["outcome"] == "success",
      :data    => (evalines["outcome"] == "success" ? evalines["result"] : evalines["failure-description"])
    }
  end
end
