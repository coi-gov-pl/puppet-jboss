require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_resourceadapter).provide(:jbosscli,
    :parent => PuppetX::Coi::Jboss::Provider::AbstractJbossCli) do

  def create
    name = @resource[:name]
    jndiname = @resource[:jndiname]
    params = prepareconfig()
    basicsParams = makejbprops params[:basics]
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}:add(#{basicsParams})"
    bringUp "Resource adapter", cmd
    createConnections
  end

  def destroy
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}:remove()"
    bringDown "Resource adapter", cmd
  end

  def exists?
    $data = nil
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}:read-resource(recursive=true)"
    res = executeAndGet(cmd)
    if not res[:result]
      Puppet.debug "Resource Adapter is not set"
      return false
    end
    $data = res[:data]
    return true
  end

  def archive
    $data['archive']
  end

  def archive= value
    setbasicattr 'archive', value
  end

  def transactionsupport
    $data['transaction-support']
  end

  def transactionsupport= value
    setbasicattr 'transaction-support', value
  end

  def jndiname
    jndis = []
    if $data['connection-definitions'].nil?
      $data['connection-definitions'] = {}
    end
    $data['connection-definitions'].each do |jndi, config|
      jndis.push jndi
    end
    given = @resource[:jndiname]
    if jndis - given == [] and given - jndis == []
      # Returning in apopriate order to prevent changes
      jndis = given
    end
    Puppet.debug "JNDI getter -------- POST! => #{jndis.inspect}"
    return jndis
  end

  def jndiname= value
    Puppet.debug "JNDI setter -------- PRE!"
    names = jndiname
    toremove = names - value # Existing array minus new provides array to be removed
    trace 'jndiname=(%s) :: toremove=%s' % [value.inspect, toremove.inspect]
    toadd = value - names    # New array minus existing provides array to be added
    trace 'jndiname=(%s) :: toadd=%s' % [value.inspect, toadd.inspect]
    toremove.each do |jndi|
      destroyconn jndi
    end
    toadd.each do |jndi|
      config = prepareconfig()
      createconn jndi, config[:connections][jndi]
    end
    exists? # Re read configuration
  end

  def classname
    getconnectionattr 'class-name'
  end

  def classname= value
    setconnectionattr 'class-name', value
  end

  def backgroundvalidation
    getconnectionattr 'background-validation'
  end

  def backgroundvalidation= value
    setconnectionattr 'background-validation', value
  end

  def security
    if PuppetX::Coi::Jboss::Functions.jboss_to_bool(getconnectionattr 'security-application')
      return 'application'
    end
    if PuppetX::Coi::Jboss::Functions.jboss_to_bool(getconnectionattr 'security-domain-and-application')
      return 'domain-and-application'
    end
    if PuppetX::Coi::Jboss::Functions.jboss_to_bool(getconnectionattr 'security-domain')
      return 'domain'
    end
    return nil
  end

  def security= value
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
    if $data.nil?
      exists? # Re read configuration
    end
    prepareconfig()[:connections].each do |jndi, config|
      if not connExists? jndi
        createconn jndi, config
      end
    end
  end

  def connExists? jndi
    if $data['connection-definitions'].nil?
      $data['connection-definitions'] = {}
    end
    if not $data['connection-definitions'][jndi].nil?
      return true
    end
    name = @resource[:name]
    connectionName = escapeforjbname jndi
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connectionName}:read-resource()"
    res = executeAndGet cmd
    if res[:result]
      $data['connection-definitions'][jndi] = res[:data]
    end
    return res[:result]
  end

  def createconn jndi, config
    name = @resource[:name]
    connectionParams = makejbprops config
    connectionName = escapeforjbname jndi
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connectionName}:add(#{connectionParams})"
    bringUp "Resource adapter connection-definition", cmd
  end

  def destroyconn jndi
    name = @resource[:name]
    connectionName = escapeforjbname jndi
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{connectionName}:remove()"
    bringDown "Resource adapter connection-definition", cmd
  end

  def prepareconfig
    params = {
      :basics => {
        'archive'             => @resource[:archive],
        'transaction-support' => @resource[:transactionsupport],
      },
      :connections => {},
    }
    if @resource[:jndiname].nil?
      @resource[:jndiname] = []
    end
    @resource[:jndiname].each do |jndiname|
      params[:connections][jndiname] = {
        'jndi-name'             => jndiname,
        'class-name'            => @resource[:classname],
        'background-validation' => @resource[:backgroundvalidation],
      }
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
    return params
  end

  def escapeforjbname input
    input.gsub(/([^\\])\//, '\1\\/').gsub(/([^\\]):/, '\1\\:')
  end

  def unescapeforjbname input
    input.gsub(/\\\//, '/').gsub(/\\:/, ':')
  end

  def makejbprops input
    inp = {}
    input.each do |k, v|
      if not v.nil?
        inp[k] = v
      end
    end
    inp.inspect.gsub('=>', '=').gsub(/[\{\}]/, '').gsub(/\"([^\"]+)\"=/,'\1=')
  end

  def setbasicattr name, value
    setattribute "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}", name, value
    $data[name] = value
  end

  def setconnectionattr name, value
    prepareconfig()[:connections].each do |jndi, config|
      if not connExists? jndi
        createconn jndi, config
        next
      end
      connectionName = escapeforjbname jndi
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
    prepareconfig()[:connections].each do |jndi, config|
      if not connExists? jndi
        return nil
      end
      if $data['connection-definitions'][jndi].nil?
        return nil
      end
      return $data['connection-definitions'][jndi][name]
    end
  end

end
