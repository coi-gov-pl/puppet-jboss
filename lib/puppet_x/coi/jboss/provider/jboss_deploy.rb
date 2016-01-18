# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss

module Provider
# A class for JBoss deploy
module JbossDeploy
  def create
    cmd = "deploy #{@resource[:source]} --name=#{@resource[:name]}"
    if @resource[:runasdomain]
      groups = @resource[:servergroups]
      if groups.nil? or groups.empty? or groups == ['']
        cmd = "#{cmd} --all-server-groups"
      else
        cmd = "#{cmd} --server-groups=#{groups.join(',')}"
      end
    end
    if @resource[:redeploy]
      cmd = "#{cmd} --force"
    end
    isprintinglog = 100
    bringUp 'Deployment', cmd
  end

  def destroy
    cmd = "undeploy #{@resource[:name]}"
    if @resource[:runasdomain]
      groups = @resource[:servergroups]
      if groups.nil? or groups.empty? or groups == ['']
        cmd = "#{cmd} --all-relevant-server-groups"
      else
        cmd = "#{cmd} --server-groups=#{groups.join(',')}"
      end
    end
    isprintinglog = 0
    bringDown 'Deployment', cmd
  end

  def exists?
    if name_exists?
      is_exact_deployment?
    else
      false
    end
  end

  def servergroups
    if not @resource[:runasdomain]
      return @resource[:servergroups]
    end
    servergroups = @resource[:servergroups]
    res = execute("deployment-info --name=#{@resource[:name]}")
    if not res[:result]
      return []
    end
    groups = []
    for line in res[:lines]
        line.strip!
        depinf = line.split
        if(depinf[1] == "enabled" || depinf[1] == "added")
            groups.push(depinf[0])
        end
    end
    if servergroups.nil? or servergroups.empty? or servergroups == ['']
      return servergroups
    end
    return groups
  end

  def servergroups=(value)
    if not @resource[:runasdomain]
      return nil
    end
    current = servergroups()
    Puppet.debug(current.inspect())
    Puppet.debug(value.inspect())

    toset = value - current
    binding.pry
    cmd = "deploy --name=#{@resource[:name]} --server-groups=#{toset.join(',')}"
    res = bringUp('Deployment', cmd)
  end

  private
  def name_exists?
    res = executeWithoutRetry "/deployment=#{@resource[:name]}:read-resource()"
    if res[:outcome] == 'failed'
        return false
    end
    unless res[:name].nil?
      Puppet.debug "Deployment found: #{res[:name]}"
      return true
    end
    Puppet.debug "No deployment matching #{@resource[:name]} found."
    return false
  end

  def is_exact_deployment?
    true
  end

end
end
end
end
end
