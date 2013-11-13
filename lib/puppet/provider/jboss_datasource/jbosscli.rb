require 'puppet/provider/jbosscli'
Puppet::Type.type(:jboss_datasource).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  desc "JBoss CLI datasource provider"
  
  $data = nil

  def create
    cmd = [ "#{create_delete_cmd} add --name=#{@resource[:name]}" ] 
    cmd.push "--jta=#{@resource[:jta]}"
    cmd.push "--jndi-name=#{@resource[:jndiname]}"
    cmd.push "--driver-name=#{@resource[:drivername]}"
    cmd.push "--min-pool-size=#{@resource[:minpoolsize]}"
    cmd.push "--max-pool-size=#{@resource[:maxpoolsize]}"
    cmd.push "--user-name=#{@resource[:username]}"
    cmd.push "--password=#{@resource[:password]}"
    cmd.push "--validate-on-match=#{@resource[:validateonmatch]}"
    cmd.push "--background-validation=#{@resource[:backgroundvalidation]}"
    cmd.push "--share-prepared-statements=#{@resource[:sharepreparedstatements]}"
    if @resource[:xa]
      cmd.push "--xa-datasource-properties={URL=#{@resource[:xadatasourceproperties]}}"
    else
      cmd.push "--connection-url=#{@resource[:xadatasourceproperties]}}"
    end
    bringUp('Datasource', cmd)
    setenabled true
  end

  def destroy
    cmd = "#{create_delete_cmd} remove --name=#{@resource[:name]}"
    bringDown('Datasource', cmd) 
  end

  def setenabled setting
    Puppet.debug "setenabled #{setting.inspect}"
    cmd = compilecmd "/subsystem=datasources/xa-data-source=#{@resource[:name]}:read-attribute(name=enabled)"
    res = execute_datasource cmd
    enabled = res[:data]
    Puppet.debug "Enabling datasource #{@resource[:name]} = #{enabled}: #{setting}"
    if enabled != setting
      if setting
        cmd = compilecmd "/subsystem=datasources/xa-data-source=#{@resource[:name]}:enable(persistent=true)"
      else
        cmd = compilecmd "/subsystem=datasources/xa-data-source=#{@resource[:name]}:disable(persistent=true)"
      end
      bringUp "Datasource enable set to #{setting.to_s}", cmd
    end
  end

  def exists?
    $data = nil
    cmd = compilecmd "/subsystem=datasources/xa-data-source=#{@resource[:name]}:read-resource(recursive=true)"
    res = execute_datasource cmd
    if(res[:result] == false)
        Puppet.debug("XA DS does NOT exist")
        return false
    end
    Puppet.debug("XA DS exists: #{res[:data].inspect}")
    $data = res[:data]
    return true
  end

  def setattrib(name, value)
    Puppet.debug(name + ' setting to ' + value)
    cmd = "/subsystem=datasources/xa-data-source=#{@resource[:name]}:write-attribute(name=#{name}, value=#{value})"
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
 
  def jndiname
    $data['jndi-name']
  end

  def jndiname=(value)
    setattrib('jndi-name', value)
  end
  
  def drivername
    $data['driver-name']
  end

  def drivername=(value)
    setattrib('driver-name', value)
  end

  def minpoolsize
    $data['min-pool-size'].to_s
  end

  def minpoolsize=(value)
    setattrib('min-pool-size', value)
  end

  def maxpoolsize
    $data['max-pool-size'].to_s
  end

  def maxpoolsize=(value)
    setattrib('max-pool-size', value)
  end

  def username
    $data['user-name']
  end

  def username=(value)
    setattrib('user-name', value)
  end

  def password
    $data['password']
  end

  def password=(value)
    setattrib('password', value)
  end

  def validateonmatch
    $data['validate-on-match'].to_s
  end

  def validateonmatch=(value)
    setattrib('validate-on-match', value.to_s)
  end

  def backgroundvalidation
    $data['background-validation'].to_s
  end

  def backgroundvalidation=(value)
    setattrib('background-validation', value.to_s)
  end

  def sharepreparedstatements
    $data['share-prepared-statements'].to_s
  end

  def sharepreparedstatements=(value)
    setattrib('share-prepared-statements', value.to_s)
  end
  
  def jta
    $data['jta'].to_s
  end

  def jta=(value)
    setattrib('jta', value.to_s)
  end
  
  def enabled
    $data['enabled'].to_s
  end

  def enabled= value
    Puppet.debug "Enabling datasource #{@resource[:name]} to #{value}"
    setenabled value
  end

  # def xadatasourceproperties
    # if($data['xa-datasource-properties'].nil? || $data['xa-datasource-properties']['URL'].nil?)
        # return nil
    # end
    # $data['xa-datasource-properties']['URL']['value']
  # end
# 
  # def xadatasourceproperties=(value)
    # Puppet.debug('XA DS URL setting to ' + value)
    # cmd = "/profile=#{@resource[:profile]}/subsystem=datasources/xa-data-source=#{@resource[:name]}/xa-datasource-properties=URL:write-attribute(name=value, value=#{value})"
    # res = execute_datasource(cmd)
    # Puppet.debug(res.inspect)
    # if not res[:result]
      # raise "Cannot set #{name}: #{res[:data]}"
    # end
  # end
  
  private
  
  def create_delete_cmd
    cmd = "data-source"
    if @resource[:xa]
      cmd = "xa-#{cmd}"
    end
    if @resource[:runasdomain]
      cmd = "#{cmd} --profile=#{@resource[:profile]}"
    end
    return cmd
  end
  
end
