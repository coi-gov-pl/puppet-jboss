require 'puppet/provider/jbosscli'

Puppet::Type.type(:jboss_confignode).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  desc "JBoss CLI configuration node provider"
  
  @clean = false
  @data = nil
  
  def create
    trace 'create'
    if exists?
      return
    end
    ret = bringUp 'Configuration node', "#{compiledpath}:add(#{compileprops})"
    invalidate
    return ret
  end

  def destroy
    trace 'destroy'
    if not exists?
      return
    end
    if status == :running
      doStop
    end
    ret = bringDown 'Configuration node', "#{compiledpath}:remove()"
    invalidate
    return ret
  end
  
  def exists?
    trace 'exists?'

    if @clean
      return (not @data.nil?)
    end
    if @resource[:path].nil?
      @resource[:path] = @resource[:name]
    end
    @resource[:properties].each do |key, value|
      if value == "undef"
        @resource[:properties][key] = nil
      end
    end
    
    res = executeAndGet "#{compiledpath}:read-resource(include-runtime=true)"
    if res[:result]
      @data = {}
      res[:data].each do |key, value|
        props = @resource[:properties]
        @data[key] = value
        if not @property_hash.key? :properties
          @property_hash[:properties] = {}
        end
        if props.key? key
          @property_hash[:properties][key] = value
        end
      end
      @clean = true
      traceout 'status()', true
      return true
    end
    @clean = true
    @data = nil
    traceout 'status()', false
    return false
  end
  
  def status
    trace 'status'
    meth = self.method 'ensure'
    ret = meth.call
    traceout 'status()', ret
    return ret
  end
  
  def ensure
    trace 'ensure'

    exists?
    if @data.nil?
      @property_hash[:ensure] = :absent
      traceout 'ensure()', :absent
      return :absent
    end
    if not @data['status'].nil?
      st = @data['status'].upcase
      if st == 'DISABLED'
        @property_hash[:ensure] = :disabled
        traceout 'ensure()', :disabled
        return :disabled
      end
      if ['RUNNING', 'STARTED'].include? st
        @property_hash[:ensure] = :running
        traceout 'ensure()', :running
        return :running
      else
        @property_hash[:ensure] = :stopped
        traceout 'ensure()', :stopped
        return :stopped
      end
    end
    if not @data['enabled'].nil?
      if @data['enabled']
        @property_hash[:ensure] = :enabled
        traceout 'ensure()', :enabled
        return :enabled
      else
        @property_hash[:ensure] = :disabled
        traceout 'ensure()', :disabled
        return :disabled
      end
    end
    if @data.length > 0
      @property_hash[:ensure] = :present
      traceout 'ensure()', :present
      return :present
    end
  end
  
  def ensure= value
    trace 'ensure=(%s)' % [ value.inspect ]
    case value
      when :present then create
      when :absent then destroy
      when :running then doStart
      when :stopped then doStop
      when :enabled then doEnable
      when :disabled then doDisable
    end
    traceout 'ensure=(%s)' % value.inspect, value.inspect
    return value
  end
  
  def enabled?
    trace 'enabled?'
    
    return status == :running
  end
  
  def stopped?
    trace 'stopped?'
    
    return status == :stopped
  end
  
  def enabled?
    trace 'enabled?'
    
    return status == :enabled
  end
  
  def disabled?
    trace 'disabled?'
    
    return status == :disabled
  end
  
  def present?
    trace 'present?'
    
    return status == :present
  end
    
  def absent?
    trace 'absent?'
    
    return status == :absent
  end
  
  def properties
    trace 'properties()'
    
    if @data.nil?
      traceout 'properties()', {}
      return {}
    else
      hash = {}
      @property_hash[:properties].each do |k, v| 
        if v.nil? or !!v == v
          hash[k.to_s] = v
        else
          hash[k.to_s] = v.to_s
        end
      end
      traceout 'properties()', hash  
      return hash
    end
  end
  
  def properties= newprops
    trace 'properties=(%s)' % newprops.inspect
    
    newprops.each do |key, value|
      if not @data.key? key or @data[key] != value
        writekey key, value
        Puppet.notice "JBoss::Property: Key `#{key}` with value `#{value.inspect}` for path `#{compiledpath}` has been set."
      end 
    end
  end
  
  private
  
  def doStart
    trace 'doStart'
    
    if status == :absent
      create
    end
    ret = bringUp 'Configuration node START', "#{compiledpath}:start()"
    invalidate
    traceout 'doStart', ret
    return ret
  end
  
  def doStop
    trace 'doStop'
    
    if status == :absent
      create
    end
    ret = bringDown 'Configuration node STOP', "#{compiledpath}:stop()"
    invalidate
    return ret
  end
  
  def doEnable
    trace 'doEnable'
    
    if status == :absent
      create
    end
    ret = bringUp 'Configuration node ENABLE', "#{compiledpath}:enable()"
    invalidate
    return ret
  end
  
  def doDisable
    trace 'doDisable'
    
    if status == :absent
      create
    end
    ret = bringDown 'Configuration node DISABLE', "#{compiledpath}:disable()"
    invalidate
    return ret
  end
  
  def invalidate
    trace 'invalidate'
    
    @clean = false
  end
  
  def writekey key, value
    trace 'writekey(%s,%s)' % [key.inspect, value.inspect]
    
    invalidate
    if value.nil?
      bringDown 'Configuration node property', "#{compiledpath}:undefine-attribute(name=#{key})"
    else
      preparedval = escape value
      bringUp 'Configuration node property', "#{compiledpath}:write-attribute(name=#{key}, value=#{preparedval})"
    end
  end
  
  def compiledpath
    trace 'compiledpath'
    
    path = @resource[:path]
    cmd = compilecmd path
  end
  
  def compileprops
    trace 'compileprops'
    
    props = @resource[:properties]
    arr = []
    props.each do |key, value|
      preparedval = escape value
      arr.push "#{key}=#{preparedval}"
    end
    arr.join ', '
  end
end