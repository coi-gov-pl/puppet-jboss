require 'digest'

# A class for JBoss deploy
module PuppetX::Coi::Jboss::Provider::Deploy
  attr_writer :digest

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
    Puppet.debug 'Refresh event from deploy'
    undeploy if @resource[:redeploy_on_refresh]
    deploy
  end

  # Method that checks if resource is present in system
  # @return [Boolean]
  def exists?
    name_exists? ? exact_deployment? : false
  end

  # Method that checks actual server group to deploy the archive
  def servergroups
    return @resource[:servergroups] unless @resource[:runasdomain]
    return @servergroups unless @servergroups.nil?
    state = execute("deployment-info --name=#{@resource[:name]}")
    return [] unless state.success?
    @servergroups = read_groups_from_output(state.output)
  end

  def servergroups=(value)
    return nil unless @resource[:runasdomain]
    current = servergroups
    Puppet.debug(current.inspect)
    Puppet.debug(value.inspect)

    toset = value - current
    cmd = "deploy --name=#{@resource[:name]} --server-groups=#{toset.join(',')}#{runtime_name_param_with_space_or_empty_string}"
    bring_up('Deployment::changeServerGroups', cmd) unless toset.empty?
  end

  private

  # Method calls read-resource to validate if deployment resource is present
  def name_exists?
    ensure_data_loaded
    return false unless @exist
    unless @data['name'].nil?
      Puppet.debug "Deployment found: #{@resource[:name]}"
      return true
    end
    Puppet.debug "No deployment matching #{@resource[:name]} found."
    false
  end

  # Method that returs true if it's actualy exact same deployment checked by hash of artifact
  # @return [Boolean]
  def exact_deployment?
    artifact_hash = digest_of_artifact
    deployed_hash = digest_of_deployed
    if artifact_hash == deployed_hash
      Puppet.debug "Same exact deployment found, compared by hash: #{artifact_hash}. Skipping deploy."
      true
    else
      Puppet.debug "Deployment hash: #{deployed_hash} differs from expected artifact hash: #{artifact_hash}. Redeploying."
      false
    end
  end

  def digest_of_artifact
    @digest = proc { Digest::SHA1.new } if @digest.nil?
    digest = @digest.call
    digest.file @resource[:source]
    digest.hexdigest.upcase
  end

  def digest_of_deployed
    ensure_data_loaded
    @data['content'].first['hash'].map { |n| format('%02X', n & 0xFF) }.join.upcase
  end

  def ensure_data_loaded
    return unless @exist.nil?
    res = execute_without_retry "/deployment=#{@resource[:name]}:read-resource()"
    @exist = res[:result]
    @data = @exist ? res[:data] : nil
  end

  def read_groups_from_output(lines)
    groups = []
    lines.split("\n").each do |line|
      line.strip!
      depinf = line.split
      groups.push(depinf[0]) if depinf[1] == 'enabled' || depinf[1] == 'added'
    end
    groups
  end

  def runtime_name_param
    @resource[:runtime_name].nil? ? '' : "--runtime-name=#{@resource[:runtime_name]}"
  end

  def runtime_name_param_with_space_or_empty_string
    @resource[:runtime_name].nil? ? '' : " #{runtime_name_param}"
  end

  def force_deploy?
    @resource[:redeploy_on_refresh] == true
  end

  # Method to deploy Java artifacts to JBoss server
  def deploy
    cmd = "deploy #{@resource[:source]} --name=#{@resource[:name]}#{runtime_name_param_with_space_or_empty_string}"
    if @resource[:runasdomain]
      cmd = append_groups_to_cmd(cmd, @resource[:servergroups])
    end
    cmd = "#{cmd} --force" if force_deploy?
    display_lines 100
    bring_up 'Deployment', cmd
    @resource[:name]
  end

  def append_groups_to_cmd(cmd, groups, all = 'all-server-groups')
    if groups_are_empty(groups)
      "#{cmd} --#{all}"
    else
      "#{cmd} --server-groups=#{groups.join(',')}"
    end
  end

  def groups_are_empty(groups)
    groups.nil? || groups.empty? || groups == ['']
  end

  # Method to undeploy Java artifacts from JBoss server
  def undeploy
    cmd = "undeploy #{@resource[:name]}"
    if @resource[:runasdomain]
      cmd = append_groups_to_cmd(cmd, @resource[:servergroups], 'all-relevant-server-groups')
    end
    display_lines 0
    bring_down 'Undeployment', cmd
    @resource[:name]
  end
end
