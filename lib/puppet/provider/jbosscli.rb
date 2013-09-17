require 'tempfile'

class Puppet::Provider::Jbosscli < Puppet::Provider
  @@bin = "bin/jboss-cli.sh"
  def self.jbossclibin
    home = self.jbosshome
    path = "#{home}/#{@@bin}"
    return path
  end

  def self.jbosshome
    home=`grep 'JBOSS_HOME=' /etc/jboss-as/jboss-as.conf 2>/dev/null | cut -d '=' -f 2`
    home.strip!
    return home
  end

  def execute(passed_args)
    file = Tempfile.new('jbosscli')
    path = file.path
    file.close
    file.unlink

    File.open(path, 'w') {|f| f.write(passed_args + "\n") }

    ENV['JBOSS_HOME'] = Puppet::Provider::Jbosscli.jbosshome
    cmd = "#{Puppet::Provider::Jbosscli.jbossclibin} --connect --file=#{path}"
    Puppet.debug("JBOSS_HOME: " + Puppet::Provider::Jbosscli.jbosshome)
    Puppet.debug("Wykonywana komenda: " + cmd)
    Puppet.debug("Komenda do JBoss-cli: " + passed_args)
    lines = `#{cmd}`
    result = $?
    Puppet.debug("Output from jbosscli: " + lines)
    Puppet.debug("Result from jbosscli: " + result.inspect)
    # deletes the temp file
    File.unlink(path)
    return {
      :result => result == 0,
      :lines => lines
    }
  end

  def execute_datasource(passed_args)
    ret = execute(passed_args)
    if ret == false
        return false
    end

    #wskazanie typu dla undefined
    undefined = nil
    evalines = eval(ret[:lines])
    return {
      :result  => evalines["outcome"] == "success",
      :data    => (evalines["outcome"] == "success" ? evalines["result"] : evalines["failure-description"])
    }
  end
end
