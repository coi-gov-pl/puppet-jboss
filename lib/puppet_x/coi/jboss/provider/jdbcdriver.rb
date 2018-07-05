# A module for Jdbcdriver
module PuppetX::Coi::Jboss::Provider::Jdbcdriver

  # Method that creates Jdbcdriver in JBoss instance
  def create
    name = @resource[:name]
    map = get_attribs_map

    cmd = compilecmd "/subsystem=datasources/jdbc-driver=#{name}:add(#{cmdlize_attribs_map map})"
    bringUp 'JDBC-Driver', cmd
  end

  # Method to remove jdbc-driver from Jboss instance.
  def destroy
    cmd = compilecmd "/subsystem=datasources/jdbc-driver=#{@resource[:name]}:remove"
    bringDown 'JDBC-Driver', cmd
  end

  # Method to check if there is jdbc-driver.
  # Method calls recursive read-resource to validate if jdbc-driver is present.
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

  # Methods set attributes for datasources to jdbc-driver
  #
  # @param {String} name a key of representing name.
  # @param {Object} value a value of attribute
  # @return a new name and value @data hash
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

  # Standard getter for driver Java class name
  def classname
    @data['driver-class-name']
  end

  # Method set attribute for classname value
  # @param {Object} value a value of classname
  def classname= value
    setattrib 'driver-class-name', value
  end

  # Standard getter for driver module name
  def modulename
    @data['driver-module-name']
  end

  # Method set attribute for modulename value
  # @param {Object} value a value of modulename
  def modulename= value
    setattrib 'driver-module-name', value
  end

  # Standard getter for datasource Java class name
  def datasourceclassname
    @data['driver-datasource-class-name']
  end

  # Method set attribute for datasourceclassname value
  # @param {Object} value a value of datasourceclassname
  def datasourceclassname= value
    setattrib 'driver-datasource-class-name', value
  end

  # Standard getter for XA datasource Java class name
  def xadatasourceclassname
    @data['driver-xa-datasource-class-name']
  end

  # Method set attribute for xadatasourceclassname value
  # @param {Object} value a value of xadatasourceclassname
  def xadatasourceclassname= value
    setattrib 'driver-xa-datasource-class-name', value
  end

  private

  # Method get attributes map
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

  # Method that prepares attributes from hash to be included in command
  # @param {Hash} input
  # @return {List}
  def cmdlize_attribs_map input
    list = []
    input.keys.sort.each do |key|
      value = input[key]
      list.push "#{key}=#{value.inspect}"
    end
    list.join ','
  end

end
