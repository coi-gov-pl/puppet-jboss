require File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'jbosscli.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss/configuration'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss/provider/datasource/pre_wildfly_provider'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss/provider/datasource/post_wildfly_provider'))
require 'uri'

Puppet::Type.type(:jboss_datasource).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  desc "JBoss CLI datasource provider"

  @data = nil
  @readed = false
  @impl = nil

  def create
    cmd = [ "#{create_delete_cmd} add --name=#{@resource[:name]}" ]
    jta_opt(cmd)
    cmd.push "--jndi-name=#{@resource[:jndiname].inspect}"
    cmd.push "--driver-name=#{@resource[:drivername].inspect}"
    cmd.push "--min-pool-size=#{@resource[:minpoolsize].inspect}"
    cmd.push "--max-pool-size=#{@resource[:maxpoolsize].inspect}"
    cmd.push "--user-name=#{@resource[:username].inspect}"
    cmd.push "--password=#{@resource[:password].inspect}"
    if @resource[:xa]
      xa_properties = xa_datasource_properties_wrapper(createXaProperties)
      cmd.push "--xa-datasource-properties=#{xa_properties}"
    else
      cmd.push "--connection-url=#{connectionUrl.inspect}"
    end
    @resource[:options].each do |attribute, value|
      cmd.push "--#{attribute}=#{value.inspect}"
    end

    bringUp 'Datasource', cmd.join(' ')
    setenabled true
  end

  def destroy
    cmd = "#{create_delete_cmd} remove --name=#{@resource[:name]}"
    bringDown 'Datasource', cmd
  end
  
  def self.instances
    runasdomain = self.config_runasdomain
    profile = self.config_profile
    controller = self.config_controller
    ctrlconfig = self.controllerConfig({ :controller  => controller })
    list = []
    cmd = self.compilecmd runasdomain, profile, "/subsystem=datasources:read-children-names(child-type=#{self.datasource_type true})"
    res = self.executeAndGet cmd, runasdomain, ctrlconfig, 0, 0
    if res[:result]
      res[:data].each do |name|
        inst = self.create_rubyobject name, true, runasdomain, profile, controller
        list.push inst
      end
    end
    cmd = self.compilecmd runasdomain, profile, "/subsystem=datasources:read-children-names(child-type=#{self.datasource_type false})"
    res = self.executeAndGet cmd, runasdomain, ctrlconfig, 0, 0
    if res[:result]
      res[:data].each do |name|
        inst = self.create_rubyobject name, false, runasdomain, profile, controller
        list.push inst
      end
    end
    return list
  end

  def setenabled setting
    Puppet.debug "setenabled #{setting.inspect}"
    cmd = compilecmd "#{datasource_path}:read-attribute(name=enabled)"
    res = executeAndGet cmd
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
  
  def prepare_resource
    if @resource.nil?
      @resource = {}
    end
    if @resource[:name].nil?
      @resource[:name] = @property_hash[:name]
    end
    if @resource[:controller].nil?
      @resource[:controller] = controller
    end
    if @resource[:runasdomain].nil?
      @resource[:runasdomain] = runasdomain
    end
    if @resource[:profile].nil?
      @resource[:profile] = profile
    end
    if @resource[:xa].nil?
      @resource[:xa] = xa
    end
  end

  def exists?
    prepare_resource
    if @resource[:dbname].nil?
      @resource[:dbname] = @resource[:name]
    end
    @data = nil
    cmd = compilecmd "#{datasource_path}:read-resource(recursive=true)"
    res = executeAndGet cmd
    if(res[:result] == false)
        Puppet.debug "Datasorce (xa: #{xa?}) `#{@resource[:name]}` does NOT exist"
        return false
    end
    Puppet.debug "Datasorce (xa: #{xa?}) `#{@resource[:name]}` exists: #{res[:data].inspect}"
    @data = res[:data]
    return true
  end
  
  def name
    @property_hash[:name]
  end
  
  def getproperty name, default=nil
    if @property_hash.nil? or (@property_hash.respond_to? :key? and not @property_hash.key? name) or @property_hash[name].nil? 
      return default
    end
    return @property_hash[name]
  end
  def xa
    setting = getproperty :xa, nil
    if not setting.nil?
      return setting
    else
      return xa?
    end
  end
  def xa= value
    actual = getproperty :xa, false
    if actual.to_s != value.to_s
      destroy
      create
    end
  end
  def controller
    getproperty :controller
  end
  def profile
    getproperty :profile, default_profile
  end
  def runasdomain
    getproperty :runasdomain
  end
  
  def jndiname
    getattrib 'jndi-name'
  end

  def jndiname= value
    setattrib 'jndi-name', value
  end
  
  def drivername
    getattrib 'driver-name'
  end

  def drivername= value
    setattrib 'driver-name', value
  end

  def minpoolsize
    getattrib('min-pool-size').to_s
  end

  def minpoolsize= value
    setattrib 'min-pool-size', value
  end

  def maxpoolsize
    getattrib('max-pool-size').to_s
  end

  def maxpoolsize= value
    setattrib 'max-pool-size', value
  end

  def username
    getattrib('user-name')
  end

  def username= value
    setattrib 'user-name', value
  end

  def password
    getattrib('password')
  end

  def password= value
    setattrib 'password', value
  end
  
  def options
    managed_fetched_options
  end
  
  def options= value
    managed_fetched_options.each do |key, fetched_value|
      expected_value = value[key]
      setattrib(key, expected_value) if expected_value != fetched_value
    end
  end
  
  def enabled
    getattrib('enabled').to_s
  end

  def enabled= value
    Puppet.debug "Enabling datasource #{@resource[:name]} to #{value}"
    setenabled value
  end
  
  def jdbcscheme
    connectionHash()[:Scheme]
  end
  
  def jdbcscheme= value
    writeConnection :Scheme, value
  end
  
  def host
    connectionHash()[:ServerName].to_s
  end
  
  def host= value
    writeConnection :ServerName, value
  end
  
  def port
    connectionHash()[:PortNumber].to_i
  end
  
  def port= value
    writeConnection :PortNumber, value
  end
  
  def dbname
    connectionHash()[:DatabaseName]
  end
  
  def dbname= value
    writeConnection :DatabaseName, value
  end

  def getattrib name, default=nil
    if not @readed
      exists?
      @readed = true
    end
    if not @data.nil? and @data.key? name
      return @data[name]
    end
    return default
  end

  def setattrib name, value
    setattribute datasource_path, name, value
    @data[name] = value
  end

  def jta
    provider_impl.jta
  end

  def jta= value
    provider_impl.jta = value
  end

  def xa?
    if not @resource[:xa].nil?
      return @resource[:xa]
    else
      return false
    end
  end

  def xa_datasource_properties_wrapper(parameters)
    provider_impl.xa_datasource_properties_wrapper(parameters)
  end

  def jta_opt(cmd)
    provider_impl.jta_opt(cmd)
  end

  protected

  def default_profile
    'full'
  end

  private

  def provider_impl
    if @impl.nil?
      if Puppet_X::Coi::Jboss::Configuration::is_pre_wildfly?
        @impl = Puppet_X::Coi::Jboss::Provider::Datasource::PreWildFlyProvider.new(self)
      else
        @impl = Puppet_X::Coi::Jboss::Provider::Datasource::PostWildFlyProvider.new(self)
      end
    end
    @impl
  end

  def managed_fetched_options
    fetched = {}
    @resource[:options].each do |k, v|
      fetched[k] = getattrib(k)
    end
    fetched
  end
  
  def self.create_rubyobject name, xa, runasdomain, profile, controller
    props = {
      :name        => name,
      :ensure      => :present,
      :provider    => :jbosscli,
      :xa          => xa,
      :runasdomain => runasdomain,
      :profile     => profile,
      :controller  => controller
    }
    obj = new(props)
    return obj
  end

  def createXaProperties
    if @resource[:drivername] == 'h2'
      "URL=#{connectionUrl.inspect}"
    else
      out = []
      props = [:ServerName, :PortNumber, :DatabaseName]
      props.each do |prop|
        value = @resource[getPuppetKey prop]
        out.push "#{prop.to_s}=#{value.inspect}"
      end
      if oracle?
        out.push 'DriverType="thin"'
      end
      out.join ','
    end
  end
  
  def writeConnection property, value
    if xa?
      if h2?
        writeXaProperty 'URL', connectionUrl
      else
        writeXaProperty property, value
      end
    else
      readed = getattrib('connection-url')
      url = connectionUrl
      if readed.nil? or readed != url
        setattrib 'connection-url', url
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
      getattrib('xa-datasource-properties')[property.to_s]['value'] = value
      return
    end
    cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property.to_s}:read-resource()"
    if execute(cmd)[:result]
      cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property.to_s}:remove()"
      bringDown "XA Datasource Property " + property.to_s, cmd
    end
    cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property.to_s}:add(value=#{escape value})"
    bringUp "XA Datasource Property set " + property.to_s, cmd
    props = getattrib 'xa-datasource-properties'
    props = {} if props.nil?
    props[property.to_s] = {} if props[property.to_s].nil?
    props[property.to_s]['value'] = value
  end
  
  def readXaProperty property
    if property == :Scheme
      key = getPuppetKey property
      scheme = @resource[key]
      if getattrib('xa-datasource-properties')[property.to_s].nil?
        getattrib('xa-datasource-properties')[property.to_s] = {}
      end
      getattrib('xa-datasource-properties')[property.to_s]['value'] = scheme
      return scheme
    end
    readed = getattrib('xa-datasource-properties')
    key = property.to_s
    if readed.nil? or readed[key].nil? or readed[key]['value'].blank?
      name = @resource[:name]
      cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{key}:read-attribute(name=value)"
      result = executeAndGet cmd
      readed[key]['value'] = result[:data] 
    end 
    return readed[key]['value']
  end
  
  def connectionHashFromXa
    if h2?
      parseConnectionUrl(readXaProperty 'URL')
    else 
      props = [:Scheme, :ServerName, :PortNumber, :DatabaseName]
      out = {}
      props.each do |sym|
        property = readXaProperty sym
        out[sym] = property
      end
      out
    end
  end
  
  def connectionHashFromStd
    parseConnectionUrl getattrib('connection-url').to_s
  end
  
  def connectionHash
    empty = {
      :Scheme       => nil,
      :ServerName   => nil,
      :PortNumber   => nil,
      :DatabaseName => nil,
    }
    begin
      if xa? then connectionHashFromXa else connectionHashFromStd end
    rescue ArgumentError => e
      Puppet.debug e
      return empty
    end
  end
  
  def oracle?
    scheme = @resource[:jdbcscheme]
    scheme[0, 6] == 'oracle'
  end
  
  def h2?
    scheme = @resource[:jdbcscheme]
    scheme[0, 2] == 'h2'
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
  
  def datasource_type
    if xa?
      "xa-data-source"
    else
      "data-source"
    end
  end
  
  def self.datasource_type xa
    if xa
      "xa-data-source"
    else
      "data-source"
    end
  end
  
  def datasource_path
    "/subsystem=datasources/#{datasource_type}=#{@resource[:name]}"
  end
  
  def parseOracleConnectionUrl(url)
    splited = url.split '@'
    scheme = splited[0].sub 'jdbc:', ''
    host, port, dbname = splited[1].split ':'
    return {
      :Scheme       => scheme,
      :ServerName   => host,
      :PortNumber   => port.to_i,
      :DatabaseName => dbname,
    }
  end
  
  def parseH2ConnectionUrl(url)
    repl = url.sub('h2:', 'h2-')
    parsed = parseOtherDbConnectionUrl(repl)
    parsed[:Scheme] = parsed[:Scheme].sub('h2-', 'h2:')
    parsed
  end
  
  def parseOtherDbConnectionUrl(url)
    uri = URI(url.sub('jdbc:', ''))
    return {
      :Scheme       => uri.scheme,
      :ServerName   => uri.host,
      :PortNumber   => uri.port,
      :DatabaseName => uri.path[1..-1],
    }
  end
  
  def parseConnectionUrl url
    begin
      if oracle?
        parseOracleConnectionUrl(url)
      elsif h2?
        parseH2ConnectionUrl(url)
      else
        parseOtherDbConnectionUrl(url)
      end
    rescue NoMethodError, ArgumentError, RuntimeError => e
      raise ArgumentError, "Invalid connection url: #{url}: #{e}"
    end
  end
  
  def connectionUrl
    scheme = @resource[:jdbcscheme]
    host = @resource[:host]
    port = @resource[:port]
    dbname = @resource[:dbname]
    if oracle?
      port = 1521 if port <= 0
      url = "#{scheme}@#{host}:#{port}:#{dbname}"
    else
      port_with_colon = if port > 0 then ":#{port}" else '' end
      url = "#{scheme}://#{host}#{port_with_colon}/#{dbname}"
    end
    return "jdbc:#{url}"
  end
  
end
