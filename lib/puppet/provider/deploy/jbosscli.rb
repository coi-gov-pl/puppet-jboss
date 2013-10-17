require 'puppet/provider/jbosscli'
Puppet::Type.type(:deploy).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  def basename
    File.basename(@resource[:source])
  end

  def create
    cmd = "deploy #{@resource[:source]} --name=#{@resource[:name]}"
    if(@resource[:servergroups])
      cmd = "#{cmd} --server-groups=#{@resource[:servergroups].join(',')}"
    else
      cmd = "#{cmd} --all-server-groups"
    end
    if(@resource[:redeploy])
      cmd = "#{cmd} --force"
    end
    res = execute(cmd)
    if not res[:result]
      raise "Deployment failed: #{res[:lines]}"
    end
  end

  def destroy
    cmd = "undeploy #{@resource[:name]}"
    #if(@resource[:servergroup])
    #  cmd = "#{cmd} --server-groups=#{@resource[:servergroup]}"
    #else
      cmd = "#{cmd} --all-relevant-server-groups"
    #end
    res = execute(cmd)
    if not res[:result]
      raise "UnDeployment failed: #{res[:lines]}"
    end
  end

  def exists?
    #groups = @resource[:servergroup].split(",")
    res = execute("deployment-info --name=#{@resource[:name]}")# --server-group=#{@resource[:servergroup]}")
    if(res[:result] == false)
        return false
    end
    for line in res[:lines]
      line.strip!
      if line =~ /^#{@resource[:name]}[ ]+/
        Puppet.debug("Deployment found: #{line}")
        return true
      end
    end
    Puppet.debug("No deployment matching #{@resource[:name]} found.")
    return false
  end

  def servergroups
      res = execute("deployment-info --name=#{@resource[:name]}")
      if(res[:result] == false)
          return []
      end
      groups = []
      for line in res[:lines]
          line.strip!
          depinf = line.split
          if(depinf[1] == "enabled")
              groups.push(depinf[0])
          end
      end
      return groups
  end

  def servergroups=(value)
      current = servergroups()
      Puppet.debug(current.inspect())
      Puppet.debug(value.inspect())

      toset = value - current
      cmd = "deploy --name=#{@resource[:name]} --server-groups=#{toset.join(',')}"
      res = execute(cmd)
      if not res[:result]
        raise "Deployment to servergroups failed: #{res[:lines]}"
      end
  end
end
