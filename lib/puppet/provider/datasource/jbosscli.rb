require 'puppet/provider/jbosscli'
Puppet::Type.type(:datasource).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  desc "JBoss CLI datasource provider"

  $data = nil

  def create
    cmd = "xa-data-source --profile=#{@resource[:profile]} add --name=#{@resource[:name]} --jndi-name=#{@resource[:jndiname]} --driver-name=#{@resource[:drivername]} --min-pool-size=#{@resource[:minpoolsize]} --max-pool-size=#{@resource[:maxpoolsize]} --user-name=#{@resource[:username]} --password=#{@resource[:password]} --validate-on-match=#{@resource[:validateonmatch]} --background-validation=#{@resource[:backgroundvalidation]} --share-prepared-statements=#{@resource[:sharepreparedstatements]} --xa-datasource-properties=Url=#{@resource[:xadatasourceproperties]},"
    res = execute(cmd)
    if not res[:result]
      raise "XA DS add failed: #{res[:lines]}"
    end
  end

  def destroy
    cmd = "xa-data-source --profile=#{@resource[:profile]} remove --name=#{@resource[:name]}"
    res = execute(cmd)
    if not res[:result]
      raise "XA DS remove failed: #{res[:lines]}"
    end
  end

  #
  def exists?
    $data = nil
    res = execute_datasource("/profile=#{@resource[:profile]}/subsystem=datasources/xa-data-source=#{@resource[:name]}:read-resource(recursive=true)")
    if(res[:result] == false)
        Puppet.debug("XA DS does NOT exist")
        return false
    end
    Puppet.debug("XA DS exists")
    $data = res[:data]
    return true
  end

  def setattrib(name, value)
    Puppet.debug(name + ' setting to ' + value)
    cmd = "/profile=#{@resource[:profile]}/subsystem=datasources/xa-data-source=#{@resource[:name]}:write-attribute(name=#{name}, value=#{value})"
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
    $data['min-pool-size']
  end

  def minpoolsize=(value)
    setattrib('min-pool-size', value)
  end

  def maxpoolsize
    $data['max-pool-size']
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
    $data['validate-on-match']
  end

  def validateonmatch=(value)
    value = 'true' if value or 'false'
    setattrib('validate-on-match', value)
  end

  def backgroundvalidation
    $data['background-validation']
  end

  def backgroundvalidation=(value)
    setattrib('background-validation', value)
  end

  def sharepreparedstatements
    $data['share-prepared-statements']
  end

  def sharepreparedstatements=(value)
    value = 'true' if value or 'false'
    setattrib('share-prepared-statements', value)
  end

  def xadatasourceproperties
    if($data['xa-datasource-properties'].nil? || $data['xa-datasource-properties']['Url'].nil?)
        return nil
    end
    $data['xa-datasource-properties']['Url']['value']
  end

  def xadatasourceproperties=(value)
    Puppet.debug('XA DS URL setting to ' + value)
    cmd = "/profile=#{@resource[:profile]}/subsystem=datasources/xa-data-source=#{@resource[:name]}/xa-datasource-properties=Url:write-attribute(name=value, value=#{value})"
    res = execute_datasource(cmd)
    Puppet.debug(res.inspect)
    if not res[:result]
      raise "Cannot set #{name}: #{res[:data]}"
    end
  end
end
