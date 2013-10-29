require 'puppet/provider/jbosscli'

Puppet::Type.type(:jboss_resourceadapter).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  
  def create
    trace 'create'
    name = @resource[:name]
    jndiname = @resource[:jndiname]
    jndiescaped = escapeforjbname @resource[:jndiname]
    params = prepareconfig()
    basicsParams = makejbprops params[:basics]
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}:add(#{basicsParams})"
    bringUp "Resource adapter", cmd
    createconn jndiescaped
  end

  def destroy
    trace 'destroy'
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}:remove()"
    bringDown "Resource adapter", cmd
  end
  
  def createconn jndiname
    trace 'createconn'
    name = @resource[:name]
    params = prepareconfig()
    connectionParams = makejbprops params[:connection]
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{jndiname}:add(#{connectionParams})"
    bringUp "Resource adapter connection-definition", cmd
  end
  
  def destroyconn jndiname
    trace 'destroyconn'
    name = @resource[:name]
    cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{name}/connection-definitions=#{jndiname}:remove()"
    bringDown "Resource adapter connection-definition", cmd
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
    jndi = getactualjndi
    Puppet.debug "JNDI getter -------- POST! => #{jndi.inspect}"
    return jndi
  end
  
  def jndiname= value
    trace 'jndiname='
    Puppet.debug "JNDI setter -------- PRE!"
    actualjndi = getactualjndi
    if not actualjndi.nil?
      actualjndi = escapeforjbname actualjndi
      destroyconn actualjndi
    end 
    newjndi = escapeforjbname value
    createconn newjndi
    exists?
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
    if to_bool(getconnectionattr 'security-application')
      return 'application'
    end
    if to_bool(getconnectionattr 'security-domain-and-application')
      return 'domain-and-application'
    end
    if to_bool(getconnectionattr 'security-domain')
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
  
  def to_bool input
    trace 'to_bool'
    return true if input == true || input =~ (/(true|t|yes|y|1)$/i)
    return false if input == false || input.nil? || input.empty? || input =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
  
  def prepareconfig
    trace 'prepareconfig'
    params = {
      :basics => {
        'archive'             => @resource[:archive],
        'transaction-support' => @resource[:transactionsupport],        
      },
      :connection => {
        'jndi-name'             => @resource[:jndiname],
        'class-name'            => @resource[:classname],
        'background-validation' => @resource[:backgroundvalidation],
      }
    }
    case @resource[:security]
    when 'application'
        params[:connection]['security-application'] = true
        params[:connection]['security-domain-and-application'] = nil
        params[:connection]['security-domain'] = nil
    when 'domain-and-application'
        params[:connection]['security-application'] = nil
        params[:connection]['security-domain-and-application'] = true
        params[:connection]['security-domain'] = nil
    when 'domain'
        params[:connection]['security-application'] = nil
        params[:connection]['security-domain-and-application'] = nil
        params[:connection]['security-domain'] = true
    end
    return params
  end
  
  def escapeforjbname input
    trace 'escapeforjbname'
    input.gsub(/([^\\])\//, '\1\\/').gsub(/([^\\]):/, '\1\\:')
  end
  
  def makejbprops input
    trace 'makejbprops'
    inp = {}
    input.each do |k, v|
      if not v.nil?
        inp[k] = v
      end
    end
    inp.inspect.gsub('=>', '=').gsub(/[\{\}]/, '').gsub(/\"([^\"]+)\"=/,'\1=')
  end
  
  def setbasicattr name, value
    trace 'setbasicattr'
    setattribute "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}", name, value
  end
  
  def setconnectionattr name, value
    trace "setconnectionattr #{name.inspect}, #{value.inspect}"
    jndiname = @resource[:jndiname]
    jndiescaped = escapeforjbname jndiname
    if value.nil?
      cmd = compilecmd "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}/connection-definitions=#{jndiescaped}:undefine-attribute(name=#{name})"
      bringDown "Resource adapter connection definition attribute #{name}", cmd
    else
      setattribute "/subsystem=resource-adapters/resource-adapter=#{@resource[:name]}/connection-definitions=#{jndiescaped}", name, value
    end
  end
  
  def getconnectionattr name
    trace "getconnectionattr #{name.inspect}"
    jndi = getactualjndi
    if jndi.nil?
      return nil
    end
    $data['connection-definitions'][jndi][name]
  end
  
  def getactualjndi
    trace 'getactualjndi'
    conndef = $data['connection-definitions']
    if not conndef.nil?
      return conndef.keys[0]  
    end
    return nil
  end
  
  def trace method
    Puppet.debug "TRACE > IN > #{method}"
  end
  
end