require 'puppet/provider/jbosscli'
Puppet::Type.type(:jboss_jdbcdriver).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  
  $data = nil

  def create
    name = @resource[:name]
    modulename = @resource[:modulename]
    datasourceclassname = @resource[:datasourceclassname]
    runasdomain = @resource[:runasdomain]
    classname = @resource[:classname]
    profile = @resource[:profile]
    if runasdomain
      dspart = "driver-xa-datasource-class-name=#{datasourceclassname}"
    else
      # FIXME: Untested on Jboss AS!
      dspart = "driver-datasource-class-name=#{datasourceclassname}"
    end
    driveropt = ''
    driveropt = ",driver-class-name=#{classname}" if classname 
    cmd = "/subsystem=datasources/jdbc-driver=#{name}:add(driver-name=#{name},driver-module-name=#{modulename},#{dspart}#{driveropt})"
    if runasdomain
      cmd = "/profile=#{profile}#{cmd}"
    end
    bringUp('JDBC-Driver', cmd)
  end

  def destroy
    cmd = "/subsystem=datasources/jdbc-driver=#{@resource[:name]}:remove"
    runasdomain = @resource[:runasdomain]
    if runasdomain
      cmd = "/profile=#{@resource[:profile]}#{cmd}"
    end
    bringDown('JDBC-Driver', cmd)
  end
  
  def exists?
    $data = nil
    cmd = "/subsystem=datasources/jdbc-driver=#{@resource[:name]}:read-resource(recursive=true)"
    runasdomain = @resource[:runasdomain]
    if runasdomain
      cmd = "/profile=#{@resource[:profile]}#{cmd}"
    end
    res = execute_datasource(cmd)
    if(res[:result] == false)
        Puppet.debug("JDBC Driver #{@resource[:name]} does NOT exist")
        return false
    end
    Puppet.debug("JDBC Driver exists: #{res[:data].inspect}")
    $data = res[:data]
    return true
  end
  
  def setattrib(name, value)
    Puppet.debug(name + ' setting to ' + value)
    cmd = "/subsystem=datasources/jdbc-driver=#{@resource[:name]}:write-attribute(name=#{name}, value=#{value})"
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
  
  def classname
    $data['driver-class-name']
  end
  
  def classname= value
    setattrib 'driver-class-name', value
  end
  
  def modulename
    $data['driver-module-name']
  end
  
  def modulename= value
    setattrib 'driver-module-name', value
  end
  
  def datasourceclassname
    if @resource[:runasdomain]
      $data['driver-xa-datasource-class-name']
    else
      $data['driver-datasource-class-name']
    end
  end
  
  def datasourceclassname= value
    if @resource[:runasdomain]
      setattrib 'driver-xa-datasource-class-name', value
      setattrib 'driver-datasource-class-name', nil
    else
      setattrib 'driver-xa-datasource-class-name', nil
      setattrib 'driver-datasource-class-name', value
    end
  end

end
