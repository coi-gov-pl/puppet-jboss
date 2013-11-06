require 'puppet/provider/jbosscli'

Puppet::Type.type(:jboss_jmsqueue).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  def create
    if runasdomain?
      profile = "--profile=#{@resource[:profile]}"
    else
      profile = ''
    end
    entries = @resource[:entries].join '", "'
    if not entries.empty?
      entries = '["%s"]' % entries
    else
      raise "Array of entries can not be empty"
    end
    durable = @resource[:durable].to_bool
    cmd = "jms-queue #{profile} add --queue-address=#{@resource[:name]} --entries=#{entries} --durable=\"#{durable.to_s}\""
    bringUp "JMS Queue", cmd
  end

  def destroy
    if runasdomain?
      profile = "--profile=#{@resource[:profile]}"
    else
      profile = ''
    end
    cmd = "jms-queue #{profile} remove --queue-address=#{@resource[:name]}"
    bringDown "JMS Queue", cmd
  end

  #
  def exists?
    $data = nil
    cmd = compilecmd "/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}:read-resource()"
    res = execute_datasource cmd

    if not res[:result]
      Puppet.debug "JMS Queue do not exists"
      return false
    end
    $data = res[:data]
    return true
  end
  
  def durable
    trace 'durable'
    Puppet.debug "Durable given: #{@resource[:durable].inspect}"
    $data['durable'].to_bool.to_s
  end
  
  def durable= value
    trace 'durable= %s' % value.to_s
    setattr 'durable', ('"%s"' % value.to_bool)
  end
  
  def entries
    trace 'entries'
    $data['entries']
  end
  
  def entries= value
    trace 'entries= %s' % value.inspect
    entries = value.join '", "'
    if not entries.empty?
      entries = '["%s"]' % entries
    else
      raise "Array of entries can not be empty"
    end
    setattr 'entries', entries 
  end
  
  private 
  
  def setattr name, value
    setattribute_raw "/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}", name, value
  end
end
