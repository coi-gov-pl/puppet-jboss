require 'puppet/provider/jbosscli'

Puppet::Type.type(:jboss_resourceadapter).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  
  def create
    trace 'create'
    name = @resource[:name]
    jndiname = @resource[:jndiname]
    params = prepareconfig()
    basicsParams = makejbprops params[:basics]
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}:add(#{basicsParams})"
    bringUp "Resource adapter", cmd
    createConnections
  end

  def destroy
    trace 'destroy'
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}:remove()"
    bringDown "Resource adapter", cmd
  end
  
  def exists?
    trace 'exists?'
    $data = nil
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}:read-resource(recursive=true)"
    res = execute_datasource(cmd)
    if not res[:result]
      Puppet.debug "Resource Adapter is not set"
      return false
    end
    $data = res[:data]
    return true
  end
  
  def archive
    trace 'archive'
    $data['archive']
  end
  
  def archive= value
    trace 'archive='
    setbasicattr 'archive', value 
  end
  
  def transactionsupport
    trace 'transactionsupport'
    $data['transaction-support']
  end
  
  def transactionsupport= value
    trace 'transactionsupport='
    setbasicattr 'transaction-support', value 
  end
  
  def jndiname
    trace 'jndiname'
    jndi = []
    $data['connection-definitions'].each do |connName, config|
      jndi.push config['jndi-name']
    end
    given = @resource[:jndiname]
    if jndi - given == [] and given - jndi == []
      # Returning in apopriate order to prevent changes
      jndi = given
    end
    Puppet.debug "JNDI getter -------- POST! => #{jndi.inspect}"
    return jndi
  end
  
  def jndiname= value
    trace 'jndiname=(%s)' % value.inspect
    Puppet.debug "JNDI setter -------- PRE!"
    toremove = jndiname - value # Existing array minus new provides array to be removed
    trace 'jndiname=(%s) :: toremove=%s' % [value.inspect, toremove.inspect]
    toadd = value - jndiname    # New array minus existing provides array to be added
    trace 'jndiname=(%s) :: toadd=%s' % [value.inspect, toadd.inspect]
    toremove.each do |jndi|
      name = escapeforjbname jndi
      destroyconn name  
    end
    toadd.each do |jndi|
      name = escapeforjbname jndi
      config = prepareconfig()
      createconn name, config[:connections][name]
    end
    exists? # Re read
  end
  
  def classname
    trace 'classname'
    getconnectionattr 'class-name'
  end
  
  def classname= value
    trace 'classname='
    setconnectionattr 'class-name', value
  end
  
  def backgroundvalidation
    trace 'backgroundvalidation'
    getconnectionattr 'background-validation'
  end
  
  def backgroundvalidation= value
    trace 'backgroundvalidation='
    setconnectionattr 'background-validation', value
  end
  
  def security
    trace 'security'
    if Coi::Puppet::Functions.to_bool(getconnectionattr 'security-application')
      return 'application'
    end
    if Coi::Puppet::Functions.to_bool(getconnectionattr 'security-domain-and-application')
      return 'domain-and-application'
    end
    if Coi::Puppet::Functions.to_bool(getconnectionattr 'security-domain')
      return 'domain'
    end
    return nil
  end
  
  def security= value
    trace 'security='
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
  end
  
  protected
  
  def createConnections
    trace 'createConnections'
    prepareconfig()[:connections].each do |connectionName, config|
      if not connExists? connectionName
        createconn connectionName, config
      end
    end
  end
  
  def connExists? connectionName
    trace 'connExists?(%s)' % [ connectionName.inspect ]
    if not $data['connection-definitions'][connectionName].nil?
      return true
    end
    name = @resource[:name]
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connectionName}:read-resource()"
    return execute(cmd)[:result]
  end
  
  def createconn connectionName, config
    trace 'createconn(%s, %s)' % [ connectionName.inspect, config.inspect ]
    name = @resource[:name]
    connectionParams = makejbprops config
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connectionName}:add(#{connectionParams})"
    bringUp "Resource adapter connection-definition", cmd
  end
  
  def destroyconn connectionName
    trace 'destroyconn(%s)' % connectionName.inspect
    name = @resource[:name]
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connectionName}:remove()"
    bringDown "Resource adapter connection-definition", cmd
  end
  
  def prepareconfig
    trace 'prepareconfig'
    params = {
      :basics => {
        'archive'             => @resource[:archive],
        'transaction-support' => @resource[:transactionsupport],        
      },
      :connections => {}
    }
    @resource[:jndiname].each do |jndiname|
      escaped = escapeforjbname jndiname
      params[:connections][escaped] = {
        'jndi-name'             => jndiname,
        'class-name'            => @resource[:classname],
        'background-validation' => @resource[:backgroundvalidation],
      }
      case @resource[:security]
      when 'application'
          params[:connections][escaped]['security-application'] = true
          params[:connections][escaped]['security-domain-and-application'] = nil
          params[:connections][escaped]['security-domain'] = nil
      when 'domain-and-application'
          params[:connections][escaped]['security-application'] = nil
          params[:connections][escaped]['security-domain-and-application'] = true
          params[:connections][escaped]['security-domain'] = nil
      when 'domain'
          params[:connections][escaped]['security-application'] = nil
          params[:connections][escaped]['security-domain-and-application'] = nil
          params[:connections][escaped]['security-domain'] = true
      end
    end
    return params
  end
  
  def escapeforjbname input
    trace 'escapeforjbname(%s)' % input.inspect
    input.gsub(/([^\\])\//, '\1\\/').gsub(/([^\\]):/, '\1\\:')
  end
  
  def makejbprops input
    trace 'makejbprops(%s)' % input.inspect
    inp = {}
    input.each do |k, v|
      if not v.nil?
        inp[k] = v
      end
    end
    inp.inspect.gsub('=>', '=').gsub(/[\{\}]/, '').gsub(/\"([^\"]+)\"=/,'\1=')
  end
  
  def setbasicattr name, value
    trace 'setbasicattr(%s, %s)' % [name.inspect, value.inspect]
    setattribute "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}", name, value
    $data[name] = value
  end
  
  def setconnectionattr name, value
    trace "setconnectionattr(#{name.inspect}, #{value.inspect})"
    prepareconfig()[:connections].each do |connectionName, config|
      jndi = config['jndi-name']
      if not connExists? jndi
        createconn connectionName, config
        next
      end
      if value.nil?
        cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}/connection-definitions=#{connectionName}:undefine-attribute(name=#{name})"
        bringDown "Resource adapter connection definition attribute #{name}", cmd
      else
        setattribute "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}/connection-definitions=#{connectionName}", name, value
      end
      $data['connection-definitions'][jndi][name] = value
    end
  end
  
  def getconnectionattr name
    trace "getconnectionattr(#{name.inspect})"
    prepareconfig()[:connections].each do |connectionName, config|
      jndi = config['jndi-name']
      if not connExists? jndi
        return nil
      end
      return $data['connection-definitions'][jndi][name]
    end
  end
  
end