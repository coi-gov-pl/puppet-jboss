# A class for JBoss deploy
module Puppet_X::Coi::Jboss::Provider::Deploy
    def create
      deploy
    end

    def destroy
      undeploy
    end

    def refresh
      undeploy unless @resource[:redeploy]
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

    def deploy
      cmd = "deploy #{@resource[:source]} --name=#{@resource[:name]}#{runtime_name_param_with_space_or_empty_string}"
      if @resource[:runasdomain]
        servergroups = @resource[:servergroups]
        if servergroups.nil? or servergroups.empty? or servergroups == ['']
          cmd = "#{cmd} --all-server-groups"
        else
          cmd = "#{cmd} --server-groups=#{servergroups.join(',')}"
        end
      end
      if @resource[:redeploy]
        cmd = "#{cmd} --force"
      end
      isprintinglog = 100
      bringUp 'Deployment', cmd
    end

    def undeploy
      cmd = "undeploy #{@resource[:name]}"
      if @resource[:runasdomain]
        servergroups = @resource[:servergroups]
        if servergroups.nil? or servergroups.empty? or servergroups == ['']
          cmd = "#{cmd} --all-relevant-server-groups"
        else
          cmd = "#{cmd} --server-groups=#{servergroups.join(',')}"
        end
      end
      isprintinglog = 0
      bringDown 'Deployment', cmd
    end

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


end
