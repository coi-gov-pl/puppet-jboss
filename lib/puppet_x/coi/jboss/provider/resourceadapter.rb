# A module for Resource Adapter
module PuppetX::Coi::Jboss::Provider::ResourceAdapter
  def create
    name = @resource[:name]
    params = prepare_config
    basics_params = make_jboss_props(params[:basics])
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}:add(#{basics_params})"
    bring_up 'Resource adapter', cmd
    create_connections
    :created
  end

  def destroy
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}:remove()"
    bring_down 'Resource adapter', cmd
    :destroyed
  end

  def exists?
    @data = nil
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}:read-resource(recursive=true)"
    res = execute_and_get(cmd)
    unless res[:result]
      Puppet.debug 'Resource Adapter is not set'
      return false
    end
    @data = res[:data]
    true
  end

  def archive
    @data['archive']
  end

  def archive=(value)
    setbasicattr 'archive', value
  end

  def transactionsupport
    @data['transaction-support']
  end

  def transactionsupport=(value)
    setbasicattr 'transaction-support', value
  end

  def jndiname
    jndis = []
    @data['connection-definitions'] = {} if @data['connection-definitions'].nil?
    @data['connection-definitions'].each do |jndi, _config|
      jndis.push jndi
    end
    given = @resource[:jndiname]
    if jndis - given == [] && given - jndis == []
      # Returning in apopriate order to prevent changes
      jndis = given
    end
    Puppet.debug "JNDI getter -------- POST! => #{jndis.inspect}"
    jndis
  end

  def jndiname=(value)
    Puppet.debug 'JNDI setter -------- PRE!'
    names = jndiname
    toremove = names - value # Existing array minus new provides array to be removed
    trace format('jndiname=(%s) :: toremove=%s', value.inspect, toremove.inspect)
    toadd = value - names    # New array minus existing provides array to be added
    trace format('jndiname=(%s) :: toadd=%s', value.inspect, toadd.inspect)
    toremove.each do |jndi|
      destroyconn jndi
    end
    toadd.each do |jndi|
      config = prepare_config
      createconn jndi, config[:connections][jndi]
    end
    exists? # Re read configuration
  end

  def classname
    getconnectionattr 'class-name'
  end

  def classname=(value)
    setconnectionattr 'class-name', value
  end

  def backgroundvalidation
    getconnectionattr 'background-validation'
  end

  def backgroundvalidation=(value)
    setconnectionattr 'background-validation', value
  end

  def security
    if PuppetX::Coi::Jboss::Functions.to_bool([getconnectionattr('security-application')])
      return 'application'
    end
    if PuppetX::Coi::Jboss::Functions.to_bool([getconnectionattr('security-domain-and-application')])
      return 'domain-and-application'
    end
    if PuppetX::Coi::Jboss::Functions.to_bool([getconnectionattr('security-domain')])
      return 'domain'
    end
    nil
  end

  def security=(value)
    if value == 'application'
      setconnectionattr 'security-application', true
      setconnectionattr 'security-domain-and-application', nil
      setconnectionattr 'security-domain', nil
    elsif value == 'domain-and-application'
      setconnectionattr 'security-application', nil
      setconnectionattr 'security-domain-and-application', true
      setconnectionattr 'security-domain', nil
    elsif value == 'domain'
      setconnectionattr 'security-application', nil
      setconnectionattr 'security-domain-and-application', nil
      setconnectionattr 'security-domain', true
    else
      raise "Invalid value for security: #{value}. Supported values are: application, domain-and-application, domain"
    end
    value
  end

  protected

  def create_connections
    if @data.nil?
      exists? # Re read configuration
    end
    prepare_config[:connections].each do |jndi, config|
      createconn jndi, config unless conn_exists? jndi
    end
  end

  def conn_exists?(jndi)
    @data['connection-definitions'] = {} if @data['connection-definitions'].nil?
    return true unless @data['connection-definitions'][jndi].nil?
    name = @resource[:name]
    connection_name = escape_jboss_name(jndi)
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connection_name}:read-resource()"
    res = execute_and_get cmd
    @data['connection-definitions'][jndi] = res[:data] if res[:result]
    res[:result]
  end

  def createconn(jndi, config)
    name = @resource[:name]
    conn_params = make_jboss_props(config)
    connection_name = escape_jboss_name(jndi)
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connection_name}:add(#{conn_params})"
    bring_up 'Resource adapter connection-definition', cmd
  end

  def destroyconn(jndi)
    name = @resource[:name]
    connection_name = escape_jboss_name(jndi)
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connection_name}:remove()"
    bring_down 'Resource adapter connection-definition', cmd
  end

  def prepare_config
    params = {
      :basics      => {
        'archive'             => @resource[:archive],
        'transaction-support' => @resource[:transactionsupport]
      },
      :connections => {}
    }
    @resource[:jndiname] = [] if @resource[:jndiname].nil?
    @resource[:jndiname].each do |jndiname|
      params[:connections][jndiname] = {
        'jndi-name'             => jndiname,
        'class-name'            => @resource[:classname],
        'background-validation' => @resource[:backgroundvalidation]
      }
      prepare_security_config(params, jndiname)
    end
    params
  end

  def prepare_security_config(params, jndiname)
    case @resource[:security]
    when 'application'
      params[:connections][jndiname]['security-application'] = true
      params[:connections][jndiname]['security-domain-and-application'] = nil
      params[:connections][jndiname]['security-domain'] = nil
    when 'domain-and-application'
      params[:connections][jndiname]['security-application'] = nil
      params[:connections][jndiname]['security-domain-and-application'] = true
      params[:connections][jndiname]['security-domain'] = nil
    when 'domain'
      params[:connections][jndiname]['security-application'] = nil
      params[:connections][jndiname]['security-domain-and-application'] = nil
      params[:connections][jndiname]['security-domain'] = true
    end
  end

  def escape_jboss_name(input)
    input.gsub(%r{([^\\])/}, '\1\\/').gsub(/([^\\]):/, '\1\\:')
  end

  def make_jboss_props(input)
    properties = PuppetX::Coi::Jboss::Hash.new
    input.each do |k, v|
      properties[k.to_s] = v unless v.nil?
    end
    collected = []
    properties.each_sorted do |k, v|
      collected.push("#{k}=#{v.inspect}")
    end
    collected.join ', '
  end

  def setbasicattr(name, value)
    setattribute "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}", name, value
    @data[name] = value
  end

  def setconnectionattr(name, value)
    prepare_config[:connections].each do |jndi, config|
      unless conn_exists? jndi
        createconn(jndi, config)
        next
      end
      connection_name = escape_jboss_name(jndi)
      do_set_connection_attr(connection_name, name, value)
      @data['connection-definitions'][jndi][name] = value
    end
  end

  def do_set_connection_attr(connection_name, name, value)
    basepath = "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}"
    conndesc = "connection-definitions=#{connection_name}"
    path = "#{basepath}/#{conndesc}"
    if value.nil?
      cmd = compilecmd "#{path}:undefine-attribute(name=#{name})"
      bring_down "Resource adapter connection definition attribute #{name}", cmd
    else
      setattribute path, name, value
    end
  end

  def getconnectionattr(name)
    prepare_config[:connections].each do |jndi, _config|
      return nil unless conn_exists? jndi
      return nil if @data['connection-definitions'][jndi].nil?
      return @data['connection-definitions'][jndi][name]
    end
  end
end
