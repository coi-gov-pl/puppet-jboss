require 'puppet/provider/jbosscli'
Puppet::Type.type(:deploy).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  commands :jbosscli => "#{Puppet::Provider::Jbosscli.jbossclibin}"


  def basename
    File.basename(@resource[:source])
  end

  def create
    cmd = "deploy #{@resource[:source]} --all-server-groups"
    return execute(cmd)[:result]
  end

  def destroy
    cmd = "undeploy #{self.basename} --all-relevant-server-groups"
    return execute(cmd)[:result]
  end

  #
  def exists?
    res = execute("ls deployment")
    for line in res[:lines]
      line.strip!
      if line == self.basename
        return true
      end
    end
    return false
  end
#
end
