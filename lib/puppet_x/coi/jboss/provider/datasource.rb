require_relative '../configuration'

# A class for JBoss datasource provider
module PuppetX::Coi::Jboss::Provider::Datasource
  include PuppetX::Coi::Jboss::Constants
  include PuppetX::Coi::Jboss::BuildinsUtils

  # Method that creates datasource in JBoss instance
  def create
    cmd = ["#{create_delete_cmd} add --name=#{@resource[:name]}"]
    jta_opt(cmd)
    cmd.push "--jndi-name=#{@resource[:jndiname].inspect}"
    cmd.push "--driver-name=#{@resource[:drivername].inspect}"
    cmd.push "--min-pool-size=#{@resource[:minpoolsize].inspect}"
    cmd.push "--max-pool-size=#{@resource[:maxpoolsize].inspect}"
    cmd.push "--user-name=#{@resource[:username].inspect}"
    cmd.push "--password=#{@resource[:password].inspect}"
    if @resource[:xa]
      xa_properties = xa_datasource_properties_wrapper(create_xa_properties)
      cmd.push "--xa-datasource-properties=#{xa_properties}"
    else
      cmd.push "--connection-url=#{connection_url.inspect}"
    end
    @resource[:options].each do |attribute, value|
      cmd.push "--#{attribute}=#{value.inspect}"
    end

    bring_up 'Datasource', cmd.join(' ')
    setenabled true
  end

  # Method that remove datasource from JBoss instance
  def destroy
    cmd = "#{create_delete_cmd} remove --name=#{@resource[:name]}"
    bring_down 'Datasource', cmd
  end

  # Method that control whether given data source should be enabled or not
  def setenabled(setting)
    Puppet.debug "setenabled #{setting.inspect}"
    cmd = compilecmd "#{datasource_path}:read-attribute(name=enabled)"
    res = execute_and_get cmd
    enabled = res[:data]
    Puppet.debug "Enabling datasource #{@resource[:name]} = #{enabled}: #{setting}"
    if enabled != setting
      cmd = if setting
              compilecmd "#{datasource_path}:enable(persistent=true)"
            else
              compilecmd "#{datasource_path}:disable(persistent=true)"
            end
      bring_up "Datasource enable set to #{setting}", cmd
    end
  end

  # Method that prepares resource that will be used later
  # @return {hash} resource
  def prepare_resource
    @resource = {} if @resource.nil?
    @resource[:name] = @property_hash[:name] if @resource[:name].nil?
    @resource[:controller] = controller if @resource[:controller].nil?
    @resource[:runasdomain] = runasdomain if @resource[:runasdomain].nil?
    @resource[:profile] = profile if @resource[:profile].nil?
    @resource[:xa] = xa if @resource[:xa].nil?
  end

  # Method that checks if resource is present in the system
  # @return {Boolean} true if there is such resource
  def exists?
    prepare_resource
    @resource[:dbname] = @resource[:name] if @resource[:dbname].nil?
    @data = nil
    cmd = compilecmd "#{datasource_path}:read-resource(recursive=true)"
    res = execute_and_get cmd
    if res[:result] == false
      Puppet.debug "Datasorce (xa: #{xa?}) `#{@resource[:name]}` does NOT exist"
      return false
    end
    Puppet.debug "Datasorce (xa: #{xa?}) `#{@resource[:name]}` exists: #{res[:data].inspect}"
    @data = res[:data]
    @readed = true
    true
  end

  def name
    @property_hash[:name]
  end

  # Method get properties.
  # @param {String} name a key for representing name.
  def getproperty(name, default = nil)
    if @property_hash.nil? || (@property_hash.respond_to?(:key?) && (!@property_hash.key? name)) || @property_hash[name].nil?
      return default
    end
    @property_hash[name]
  end

  def xa
    setting = getproperty :xa, nil
    if !setting.nil?
      return setting
    else
      return xa?
    end
  end

  # Method indicate that given data source should XA or Non-XA
  # Default is equal to 'false'
  # @param {Boolean} value a value of xa, can be true or false
  def xa=(value)
    actual = getproperty :xa, false
    if actual.to_s != value.to_s
      destroy
      create
    end
  end

  # Standard getter for domain controller
  def controller
    getproperty :controller
  end

  # Standard getter for domain profile in JBoss server
  def profile
    getproperty :profile, default_profile
  end

  # Standard getter for runasdomain
  def runasdomain
    getproperty :runasdomain
  end

  # Standard getter for jndiname under wich the datasource wrapper will be bound
  def jndiname
    getattrib 'jndi-name'
  end

  # Standard setter
  def jndiname=(value)
    setattrib 'jndi-name', value
  end

  # Standard getter
  def drivername
    getattrib 'driver-name'
  end

  # Standard setter
  def drivername=(value)
    setattrib 'driver-name', value
  end

  # Standard getter
  def minpoolsize
    getattrib('min-pool-size').to_s
  end

  # Standard setter
  def minpoolsize=(value)
    setattrib 'min-pool-size', value
  end

  # Standard getter
  def maxpoolsize
    getattrib('max-pool-size').to_s
  end

  # Standard setter
  def maxpoolsize=(value)
    setattrib 'max-pool-size', value
  end

  # Standard getter
  def username
    getattrib('user-name')
  end

  # Standard setter
  def username=(value)
    setattrib 'user-name', value
  end

  # Standard getter
  def password
    getattrib('password')
  end

  # Standard setter
  def password=(value)
    setattrib 'password', value
  end

  # Standard getter
  def options
    managed_fetched_options
  end

  # Standard setter
  def options=(value)
    managed_fetched_options.each do |key, fetched_value|
      expected_value = ABSENTLIKE.include?(value) ? nil : value[key]
      setattrib(key, expected_value) if expected_value != fetched_value
    end
  end

  def enabled
    getattrib('enabled').to_s
  end

  # Standard setter
  def enabled=(value)
    Puppet.debug "Enabling datasource #{@resource[:name]} to #{value}"
    setenabled value
  end

  def jdbcscheme
    connection_hash[:Scheme]
  end

  # Standard setter
  def jdbcscheme=(value)
    write_connection :Scheme, value
  end

  def host
    connection_hash[:ServerName].to_s
  end

  # Standard setter
  def host=(value)
    write_connection :ServerName, value
  end

  def port
    connection_hash[:PortNumber].to_i
  end

  # Standard setter
  def port=(value)
    write_connection :PortNumber, value
  end

  def dbname
    connection_hash[:DatabaseName]
  end

  # Standard setter
  def dbname=(value)
    write_connection :DatabaseName, value
  end

  def getattrib(name, default = nil)
    exists? unless @readed
    return @data[name] unless @data.nil? || !@data.key?(name)
    default
  end

  def setattrib(name, value)
    setattribute datasource_path, name, value
    @data[name] = value
  end

  def jta
    provider_impl.jta
  end

  # Standard setter for jta
  def jta=(value)
    provider_impl.jta = value
  end

  # Method that checks if we want to run xa resource
  # @return [Boolean]
  def xa?
    if !@resource[:xa].nil?
      @resource[:xa]
    else
      false
    end
  end

  # Standard setter for xa_datasource_properties_wrapper
  def xa_datasource_properties_wrapper(parameters)
    provider_impl.xa_datasource_properties_wrapper(parameters)
  end

  # Standard setter for jta_opt
  def jta_opt(cmd)
    provider_impl.jta_opt(cmd)
  end

  protected

  def default_profile
    'full'
  end

  private

  def provider_impl
    require_relative 'datasource/pre_wildfly_provider'
    require_relative 'datasource/post_wildfly_provider'

    if @impl.nil?
      @impl = if PuppetX::Coi::Jboss::Configuration.pre_wildfly?
                PuppetX::Coi::Jboss::Provider::Datasource::PreWildFlyProvider.new(self)
              else
                PuppetX::Coi::Jboss::Provider::Datasource::PostWildFlyProvider.new(self)
              end
    end
    @impl
  end

  def managed_fetched_options
    fetched = {}
    @resource[:options].keys.each do |k|
      fetched[k] = getattrib(k)
    end
    fetched
  end

  def create_xa_properties
    if @resource[:drivername] == 'h2'
      "URL=#{connection_url.inspect}"
    else
      out = []
      props = [:ServerName, :PortNumber, :DatabaseName]
      props.each do |prop|
        value = @resource[get_puppet_key prop]
        out.push "#{prop}=#{value.inspect}"
      end
      out.push 'DriverType="thin"' if oracle?
      out.join ','
    end
  end

  def write_connection(property, value)
    if xa?
      if h2?
        write_xa_property 'URL', connection_url
      else
        write_xa_property property, value
      end
    else
      readed = getattrib('connection-url')
      url = connection_url
      setattrib 'connection-url', url if readed.nil? && readed != url
    end
  end

  def get_puppet_key(property)
    dictionary = {
      :Scheme       => :jdbcscheme,
      :ServerName   => :host,
      :PortNumber   => :port,
      :DatabaseName => :dbname
    }
    raise "Unknown property: #{property}" unless dictionary.key?(property)
    dictionary[property]
  end

  def write_xa_property(property, value)
    if property == :Scheme
      getattrib('xa-datasource-properties')[property.to_s]['value'] = value
      return
    end
    cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property}:read-resource()"
    if execute(cmd).success?
      cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property}:remove()"
      bring_down 'XA Datasource Property ' + property.to_s, cmd
    end
    cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{property}:add(value=#{escape value})"
    bring_up 'XA Datasource Property set ' + property.to_s, cmd
    props = getattrib 'xa-datasource-properties'
    props = {} if props.nil?
    props[property.to_s] = {} if props[property.to_s].nil?
    props[property.to_s]['value'] = value
  end

  def read_xa_property(property)
    if property == :Scheme
      key = get_puppet_key property
      scheme = @resource[key]
      if getattrib('xa-datasource-properties')[property.to_s].nil?
        getattrib('xa-datasource-properties')[property.to_s] = {}
      end
      getattrib('xa-datasource-properties')[property.to_s]['value'] = scheme
      return scheme
    end
    readed = getattrib('xa-datasource-properties')
    key = property.to_s
    bm = BlankMatcher.new(readed[key]['value'])
    if readed.nil? || readed[key].nil? || bm.blank?
      name = @resource[:name]
      cmd = compilecmd "#{datasource_path}/xa-datasource-properties=#{key}:read-attribute(name=value)"
      result = execute_and_get cmd
      readed[key]['value'] = result[:data]
    end
    readed[key]['value']
  end

  def connection_hash_from_xa
    if h2?
      parse_connection_url(read_xa_property('URL'))
    else
      props = [:Scheme, :ServerName, :PortNumber, :DatabaseName]
      out = {}
      props.each do |sym|
        property = read_xa_property sym
        out[sym] = property
      end
      out
    end
  end

  def connection_hash_from_std
    parse_connection_url getattrib('connection-url').to_s
  end

  def connection_hash
    empty = {
      :Scheme       => nil,
      :ServerName   => nil,
      :PortNumber   => nil,
      :DatabaseName => nil
    }
    begin
      xa? ? connection_hash_from_xa : connection_hash_from_std
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
    cmd = 'data-source'
    cmd = "xa-#{cmd}" if xa?
    cmd = "#{cmd} --profile=#{@resource[:profile]}" if @resource[:runasdomain]
    cmd
  end

  def datasource_type
    if xa?
      'xa-data-source'
    else
      'data-source'
    end
  end

  def datasource_path
    "/subsystem=datasources/#{datasource_type}=#{@resource[:name]}"
  end

  def parse_oracle_connection_url(url)
    splited = url.split '@'
    scheme = splited[0].sub 'jdbc:', ''
    host, port, dbname = splited[1].split ':'
    {
      :Scheme       => scheme,
      :ServerName   => host,
      :PortNumber   => port.to_i,
      :DatabaseName => dbname
    }
  end

  def parse_h2_connection_url(url)
    repl = url.sub('h2:', 'h2-')
    parsed = parse_other_db_connection_url(repl)
    parsed[:Scheme] = parsed[:Scheme].sub('h2-', 'h2:')
    parsed
  end

  def parse_other_db_connection_url(url)
    uri = URI(url.sub('jdbc:', ''))
    {
      :Scheme       => uri.scheme,
      :ServerName   => uri.host,
      :PortNumber   => uri.port,
      :DatabaseName => uri.path[1..-1]
    }
  end

  def parse_connection_url(url)
    if oracle?
      parse_oracle_connection_url(url)
    elsif h2?
      parse_h2_connection_url(url)
    else
      parse_other_db_connection_url(url)
    end
  rescue NoMethodError, ArgumentError, RuntimeError => e
    raise ArgumentError, "Invalid connection url: #{url}: #{e}"
  end

  def connection_url
    scheme = @resource[:jdbcscheme]
    host = @resource[:host]
    port = @resource[:port]
    dbname = @resource[:dbname]
    if oracle?
      port = 1521 if port <= 0
      url = "#{scheme}@#{host}:#{port}:#{dbname}"
    else
      port_with_colon = port > 0 ? ":#{port}" : ''
      url = "#{scheme}://#{host}#{port_with_colon}/#{dbname}"
    end
    "jdbc:#{url}"
  end
end
