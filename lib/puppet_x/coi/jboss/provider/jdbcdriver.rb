# A module for Jdbcdriver
module Puppet_X::Coi::Jboss::Provider::Jdbcdriver

  # Method that creates Jdbcdriver in JBoss instance
  def create
    name = @resource[:name]
    map = get_attribs_map

    cmd = compilecmd "/subsystem=datasources/jdbc-driver=#{name}:add(#{cmdlize_attribs_map map})"
    bringUp 'JDBC-Driver', cmd
  end

  def destroy
    cmd = compilecmd "/subsystem=datasources/jdbc-driver=#{@resource[:name]}:remove"
    bringDown 'JDBC-Driver', cmd
  end

  def exists?
    @data = {}
    cmd = compilecmd "/subsystem=datasources/jdbc-driver=#{@resource[:name]}:read-resource(recursive=true)"
    res = executeAndGet cmd
    if(res[:result] == false)
        Puppet.debug("JDBC Driver #{@resource[:name]} does NOT exist")
        return false
    end
    Puppet.debug("JDBC Driver exists: #{res[:data].inspect}")
    @data = res[:data]
    return true
  end

  def setattrib name, value
    Puppet.debug(name + ' setting to ' + value)
    cmd = compilecmd "/subsystem=datasources/jdbc-driver=#{@resource[:name]}:write-attribute(name=#{name}, value=#{value})"
    res = executeAndGet cmd
    Puppet.debug res.inspect
    if not res[:result]
      raise "Cannot set #{name}: #{res[:data]}"
    end
    @data[name] = value
  end

  def classname
    @data['driver-class-name']
  end

  def classname= value
    setattrib 'driver-class-name', value
  end

  def modulename
    @data['driver-module-name']
  end

  def modulename= value
    setattrib 'driver-module-name', value
  end

  def datasourceclassname
    @data['driver-datasource-class-name']
  end

  def datasourceclassname= value
    setattrib 'driver-datasource-class-name', value
  end

  def xadatasourceclassname
    @data['driver-xa-datasource-class-name']
  end

  def xadatasourceclassname= value
    setattrib 'driver-xa-datasource-class-name', value
  end

  private

  def get_attribs_map
    name = @resource[:name]
    modulename = @resource[:modulename]
    datasourceclassname = @resource[:datasourceclassname]
    xadatasourceclassname = @resource[:xadatasourceclassname]
    classname = @resource[:classname]
    map = {
      'driver-name'        => name,
      'driver-module-name' => modulename
    }
    map['driver-datasource-class-name'] = datasourceclassname if datasourceclassname
    map['driver-xa-datasource-class-name'] = xadatasourceclassname if xadatasourceclassname
    map['driver-class-name'] = classname if classname
    map
  end

  def cmdlize_attribs_map input
    list = []
    input.keys.sort.each do |key|
      value = input[key]
      list.push "#{key}=#{value.inspect}"
    end
    list.join ','
  end

end
