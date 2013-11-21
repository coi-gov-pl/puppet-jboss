require 'puppet/provider/jbosscli'
require 'uri'
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
      cmd.push "--xa-datasource-properties=[#{createXaProperties}]"
    else
      cmd.push "--connection-url=#{connectionUrl}"
    end
    bringUp 'Datasource', cmd.join(' ')
    setenabled true
  end

  def destroy
    cmd = "#{create_delete_cmd} remove --name=#{@resource[:name]}"
    bringDown 'Datasource', cmd
  end

  def setenabled setting
    Puppet.debug "setenabled #{setting.inspect}"
    cmd = compilecmd "#{datasource_path}:read-attribute(name=enabled)"
    res = execute_datasource cmd
    enabled = res[:data]
    Puppet.debug "Enabling datasource #{@resource[:name]} = #{enabled}: #{setting}"
    if enabled != setting
      if setting
        cmd = compilecmd "#{datasource_path}:enable(persistent=true)"
      else
        cmd = compilecmd "#{datasource_path}:disable(persistent=true)"
      end
      bringUp "Datasource enable set to #{setting.to_s}", cmd
    end
  end

  def exists?
    if @resource[:dbname].nil?
      @resource[:dbname] = @resource[:name]
    end
    $data = nil
    cmd = compilecmd "#{datasource_path}:read-resource(recursive=true)"
    res = execute_datasource cmd
    if(res[:result] == false)
        Puppet.debug "Datasorce (xa: #{xa?}) `#{@resource[:name]}` does NOT exist"
        return false
    end
    Puppet.debug "Datasorce (xa: #{xa?}) `#{@resource[:name]}` exists: #{res[:data].inspect}"
    $data = res[:data]
    return true
  end

  def setattrib name, value
    Puppet.debug name + ' setting to ' + value
    cmd = compilecmd "#{datasource_path}:write-attribute(name=#{name}, value=#{value})"
    res = execute_datasource cmd
    Puppet.debug res.inspect
    if not res[:result]
      raise "Cannot set #{name}: #{res[:data]}"
    end
  end 
 
  def jndiname
    $data['jndi-name']
  end

  def jndiname= value
    setattrib 'jndi-name', value
  end
  
  def drivername
    $data['driver-name']
  end

  def drivername= value
    setattrib 'driver-name', value
  end

  def minpoolsize
    $data['min-pool-size'].to_s
  end

  def minpoolsize= value
    setattrib 'min-pool-size', value
  end

  def maxpoolsize
    $data['max-pool-size'].to_s
  end

  def maxpoolsize= value
    setattrib 'max-pool-size', value
  end

  def username
    $data['user-name']
  end

  def username= value
    setattrib 'user-name', value
  end

  def password
    $data['password']
  end

  def password= value
    setattrib 'password', value
  end

  def validateonmatch
    $data['validate-on-match'].to_s
  end

  def validateonmatch= value
    setattrib 'validate-on-match', value.to_s
  end

  def backgroundvalidation
    $data['background-validation'].to_s
  end

  def backgroundvalidation= value
    setattrib 'background-validation', value.to_s
  end

  def sharepreparedstatements
    $data['share-prepared-statements'].to_s
  end

  def sharepreparedstatements= value
    setattrib 'share-prepared-statements', value.to_s
  end
  
  def jta
    $data['jta'].to_s
  end

  def jta= value
    setattrib 'jta', value.to_s
  end
  
  def enabled
    $data['enabled'].to_s
  end

  def enabled= value
    Puppet.debug "Enabling datasource #{@resource[:name]} to #{value}"
    setenabled value
  end
  
  def jdbcscheme
    connectionHash[:Scheme]
  end
  
  def jdbcscheme= value
    writeConnection :Scheme, value
  end
  
  def host
    connectionHash[:ServerName]
  end
  
  def host= value
    writeConnection :ServerName, value
  end
  
  def port
    connectionHash[:PortNumber]
  end
  
  def port= value
    writeConnection :PortNumber, value
  end
  
  def dbname
    connectionHash[:DatabaseName]
  end
  
  def dbname= value
    writeConnection :DatabaseName, value
  end
  
  private
  
  def createXaProperties
    out = []
    props = [:ServerName, :PortNumber, :DatabaseName]
    props.each do |prop|
      value = @resource[getPuppetKey prop]
      out.push "#{prop.to_s}=#{value}" 
    end
    out.join ','
  end
  
  def writeConnection property, value
    if xa?
      writeXaProperty property, value
    else
      readed = $data['connection-url']
      url = connectionUrl
      if readed.nil? or readed != url
        setattrib 'connection-url', url
        $data['connection-url'] = url
      end
    end
  end
  
  def getPuppetKey property
    case property
      when :Scheme
        return :jdbcscheme
      when :ServerName
        return :host
      when :PortNumber
        return :port
      when :DatabaseName
        return :dbname
      else
        raise 'Unknown property: ' + property
    end
  end
  
  def writeXaProperty property, value
    if property == :Scheme
      $data['xa-datasource-properties'][property.to_s]['value'] = value
      return
    end
    cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property.to_s}:read-resource()"
    if not execute(cmd)[:result]
      cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property.to_s}:add()"
      bringUp "XA Datasource Property " + property.to_s, cmd
    end
    cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property.to_s}:write-attribute(name=value,value=#{value})"
    bringUp "XA Datasource Property set " + property.to_s, cmd
    $data['xa-datasource-properties'][property.to_s]['value'] = value
  end
  
  def readXaProperty property
    if property == :Scheme
      $data['xa-datasource-properties'][property.to_s]['value'] = @resource[getPuppetKey property]
      return @resource[getPuppetKey property]
    end
    readed = $data['xa-datasource-properties']
    if readed.nil? or readed[property.to_s].nil? or readed[property.to_s]['value'].nil?
      name = @resource[:name]
      cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property.to_s}:read-attribute(name=value)"
      result = execute_datasource cmd
      readed[property.to_s]['value'] = result[:data] 
    end 
    return readed[property.to_s]['value']
  end
  
  def connectionHashFromXa
    props = [:ServerName, :PortNumber, :DatabaseName]
    ret = {}
    props.each do |sym|
      ret[sym] = readXaProperty sym
    end
    return ret
  end
  
  def connectionHashFromStd
    parseConnectionUrl $data['connection-url'].to_s
  end
  
  def connectionHash
    if xa?
      begin
        return connectionHashFromXa
      rescue Exception => e
        Puppet.debug e
        return {
          :Scheme       => nil,
          :ServerName   => nil,
          :PortNumber   => nil,
          :DatabaseName => nil,
        }
      end
    else
      begin
        return connectionHashFromStd
      rescue Exception => e
        Puppet.debug e
        return {
          :Scheme       => nil,
          :ServerName   => nil,
          :PortNumber   => nil,
          :DatabaseName => nil,
        }
      end
    end
  end
  
  def xa?
    @resource[:xa]
  end
  
  def oracle?
    scheme = @resource[:jdbcscheme]
    scheme[0, 6] == 'oracle'
  end
  
  def create_delete_cmd
    cmd = "data-source"
    if xa?
      cmd = "xa-#{cmd}"
    end
    if @resource[:runasdomain]
      cmd = "#{cmd} --profile=#{@resource[:profile]}"
    end
    return cmd
  end
  
  def datasource_path
    if xa?
      "/subsystem=datasources/xa-data-source=#{@resource[:name]}"
    else
      "/subsystem=datasources/data-source=#{@resource[:name]}"
    end
  end
  
  def parseConnectionUrl url
    begin
      if oracle?
        splited = url.split '@'
        scheme = splited[0].sub 'jdbc:', ''
        host, port, dbname = splited[1].split ':'
        return {
          :Scheme       => scheme,
          :ServerName   => host,
          :PortNumber   => port.to_i,
          :DatabaseName => dbname,
        }
      else
        uri = URI(url.sub('jdbc:', ''))
        return {
          :Scheme       => uri.scheme,
          :ServerName   => uri.host,
          :PortNumber   => uri.port,
          :DatabaseName => uri.path[1..-1],
        }
      end
    rescue
      raise "Invalid connection url: #{url}"
    end
  end
  
  def connectionUrl
    scheme = @resource[:jdbcscheme]
    host = @resource[:host]
    port = @resource[:port]
    dbname = @resource[:dbname]
    if oracle?
      url = "#{scheme}@#{host}:#{port}:#{dbname}"
    else
      url = "#{scheme}://#{host}:#{port}/#{dbname}"
    end
    return "jdbc:#{url}"
  end
  
end
