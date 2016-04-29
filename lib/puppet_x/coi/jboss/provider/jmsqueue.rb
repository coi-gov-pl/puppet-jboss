# A module for Jmsqueue
module Puppet_X::Coi::Jboss::Provider::Jmsqueue
  include Puppet_X::Coi::Jboss::BuildinsUtils

  # Method that creates jms-queue in JBoss instance.
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
    durable = ToBooleanConverter.new(@resource[:durable]).to_bool
    extcmd = "/extension=org.jboss.as.messaging"
    if not execute("#{extcmd}:read-resource()")[:result]
      bringUp "Extension - messaging", "#{extcmd}:add()"
    end
    syscmd = compilecmd "/subsystem=messaging"
    if not execute("#{syscmd}:read-resource()")[:result]
      bringUp "Subsystem - messaging", "#{syscmd}:add()"
    end
    hornetcmd = compilecmd "/subsystem=messaging/hornetq-server=default"
    if not execute("#{hornetcmd}:read-resource()")[:result]
      bringUp "Default HornetQ", "#{hornetcmd}:add()"
    end
    cmd = "jms-queue #{profile} add --queue-address=#{@resource[:name]} --entries=#{entries} --durable=#{durable.to_s}"
    bringUp "JMS Queue", cmd
  end

  # Method to remove jms-queue from Jboss instance.
  def destroy
    if runasdomain?
      profile = "--profile=#{@resource[:profile]}"
    else
      profile = ''
    end
    cmd = "jms-queue #{profile} remove --queue-address=#{@resource[:name]}"
    bringDown "JMS Queue", cmd
  end

  # Method to check if ther is jms-queue. Methods calls read-resource to validate if jms-queue is present.
  def exists?
    $data = nil
    cmd = compilecmd "/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}:read-resource()"
    res = executeAndGet cmd

    if not res[:result]
      Puppet.debug "JMS Queue do not exists"
      return false
    end
    $data = res[:data]
    return true
  end

  # Standard getter for durable value.
  def durable
    trace 'durable'
    Puppet.debug "Durable given: #{@resource[:durable].inspect}"
    # normalization
    ToBooleanConverter.new($data['durable']).to_bool.to_s
  end

  # Standard setter for durable value.
  #
  # @param {Boolean} value a value of durable, can be true or false
  def durable= value
    trace 'durable= %s' % value.to_s
    setattr 'durable', ('"%s"' % ToBooleanConverter.new(value).to_bool)
  end

  # Standard getter for entries value.
  def entries
    trace 'entries'
    $data['entries']
  end

  # Standard setter for entries value.
  #
  # @param {Array} value a value of entries
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

  # Methods set attributes for messaging to default hornetq-server
  # @param {String} name a key for representing name.
  # @param {Object} value a value of attribute
  def setattr name, value
    setattribute_raw "/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}", name, value
  end
end
