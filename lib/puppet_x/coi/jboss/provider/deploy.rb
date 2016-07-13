# A class for JBoss deploy
module Puppet_X::Coi::Jboss::Provider::Deploy

  # Method that creates deploy Java artifacts to JBoss server
  def create
    deploy
  end

  # Method that remove deploy from JBoss instance
  def destroy
    undeploy
  end

  # Method that force redeploy of already deployed archive
  def redeploy_on_refresh
    Puppet.debug('Refresh event from deploy')
    undeploy if @resource[:redeploy_on_refresh]
    deploy
  end

  def is_exact_deployment?
    true
  end

  def exists?
    if name_exists?
      is_exact_deployment?
    else
      false
    end
  end

  # Method that checks actual server group to deploy the archive
  def servergroups
    return @resource[:servergroups] unless @resource[:runasdomain]
    servergroups = @resource[:servergroups]
    res = execute("deployment-info --name=#{@resource[:name]}")
    return [] unless res[:result]
    groups = []
    for line in res[:lines]
      line.strip!
      depinf = line.split
      groups.push(depinf[0]) if depinf[1] == 'enabled' || depinf[1] == 'added'
    end
    if servergroups.nil? || servergroups.empty? || servergroups == ['']
      return servergroups
    end
    groups
  end

  def servergroups=(value)
    return nil unless @resource[:runasdomain]
    current = servergroups
    Puppet.debug(current.inspect)
    Puppet.debug(value.inspect)

    toset = value - current
    cmd = "deploy --name=#{@resource[:name]} --server-groups=#{toset.join(',')}#{runtime_name_param_with_space_or_empty_string}"
    res = bringUp('Deployment', cmd)
  end

  private

  def runtime_name_param
    if @resource[:runtime_name].nil?
      ''
    else
      "--runtime-name=#{@resource[:runtime_name]}"
    end
  end

  def runtime_name_param_with_space_or_empty_string
    if @resource[:runtime_name].nil?
      ''
    else
      " #{runtime_name_param}"
    end
  end

  # Method to deploy Java artifacts to JBoss server
  def deploy
    cmd = "deploy #{@resource[:source]} --name=#{@resource[:name]}#{runtime_name_param_with_space_or_empty_string}"
    if @resource[:runasdomain]
      servergroups = @resource[:servergroups]
      cmd = if servergroups.nil? || servergroups.empty? || servergroups == ['']
              "#{cmd} --all-server-groups"
            else
              "#{cmd} --server-groups=#{servergroups.join(',')}"
            end
    end
    cmd = "#{cmd} --force" if @resource[:redeploy_on_refresh]
    isprintinglog = 100
    bringUp 'Deployment', cmd
  end

  # Method to undeploy Java artifacts from JBoss server
  def undeploy
    cmd = "undeploy #{@resource[:name]}"
    if @resource[:runasdomain]
      servergroups = @resource[:servergroups]
      cmd = if servergroups.nil? || servergroups.empty? || servergroups == ['']
              "#{cmd} --all-relevant-server-groups"
            else
              "#{cmd} --server-groups=#{servergroups.join(',')}"
            end
    end
    isprintinglog = 0
    bringDown 'Deployment', cmd
  end

  # Method calls read-resource to validate if deployment resource is present
  def name_exists?
    res = executeWithoutRetry "/deployment=#{@resource[:name]}:read-resource()"
    return false if res[:outcome] == 'failed'
    unless res[:name].nil?
      Puppet.debug "Deployment found: #{res[:name]}"
      return true
    end
    Puppet.debug "No deployment matching #{@resource[:name]} found."
    false
  end
end
