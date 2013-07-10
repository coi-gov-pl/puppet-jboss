class Puppet::Provider::Jbosscli < Puppet::Provider
  @@bin = "bin/jboss-cli.sh"

  def self.jbossclibin
    home = self.jbosshome
    path = "#{home}/#{@@bin}"
    return path
  end

  def self.jbosshome
    home=`grep 'JBOSS_HOME=' /etc/jboss-as/jboss-as.conf | cut -d '=' -f 2`
    home.strip!
    return home
  end

  def execute(passed_args)
    cmd = "#{Puppet::Provider::Jbosscli.jbossclibin} --connect -c \"#{passed_args}\""
    Puppet.debug("Wykonywana komenda: " + cmd)
    lines = `#{cmd}`
    result = $?
    if result != 0
      fail lines
    end
    return {
        :result => result == 0,
        :lines => lines
    }
  end
end