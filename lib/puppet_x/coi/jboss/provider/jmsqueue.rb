# A module for Jmsqueue
module Puppet_X::Coi::Jboss::Provider::Jmsqueue
  include Puppet_X::Coi::Jboss::BuildinsUtils

  # Method that creates jms-queue in JBoss instance.
  def create
    profile = calc_profile
    entries = @resource[:entries].join '", "'
    raise 'Array of entries can not be empty' if entries.empty?
    entries = format('["%s"]', entries)
    durable = ToBooleanConverter.new(@resource[:durable]).to_bool
    ensure_default_hornetq
    cmd = "jms-queue #{profile} add --queue-address=#{@resource[:name]} " \
      "--entries=#{entries} --durable=#{durable}"
    bringUp 'JMS Queue', cmd
  end

  # Method to remove jms-queue from Jboss instance.
  def destroy
    profile = calc_profile
    cmd = "jms-queue #{profile} remove --queue-address=#{@resource[:name]}"
    bringDown 'JMS Queue', cmd
  end

  # Method to check if there is jms-queue. Methods calls read-resource to validate if jms-queue is present.
  def exists?
    result = loaddata
    unless result[:result]
      Puppet.debug 'JMS Queue do not exists'
      return false
    end
    true
  end

  # Standard getter for durable value.
  def durable
    trace 'durable'
    Puppet.debug "Durable given: #{@resource[:durable].inspect}"
    # normalization
    ToBooleanConverter.new(@data['durable']).to_bool.to_s
  end

  # Standard setter for durable value.
  #
  # @param {Boolean} value a value of durable, can be true or false
  def durable=(value)
    trace format('durable= %s', value.to_s)
    setattr 'durable', format('"%s"', ToBooleanConverter.new(value).to_bool)
  end

  # Standard getter for entries value.
  def entries
    trace 'entries'
    @data['entries']
  end

  # Standard setter for entries value.
  #
  # @param {Array} value a value of entries
  def entries=(value)
    trace format('entries= %s', value.inspect)
    entries = value.join '", "'
    raise 'Array of entries can not be empty' if entries.empty?

    entries = format('["%s"]', entries)
    setattr 'entries', entries
  end

  private

  def calc_profile
    if is_runasdomain
      "--profile=#{@resource[:profile]}"
    else
      ''
    end
  end

  def ensure_default_hornetq
    bring_up_if_needed 'Extension - messaging', '/extension=org.jboss.as.messaging'
    bring_up_if_needed 'Subsystem - messaging', compilecmd('/subsystem=messaging')
    bring_up_if_needed 'Default HornetQ', compilecmd('/subsystem=messaging/hornetq-server=default')
  end

  def bring_up_if_needed(label, clipath)
    bringUp label, "#{clipath}:add()" unless execute("#{clipath}:read-resource()")[:result]
  end

  def loaddata
    return unless @data.nil?
    @data = nil
    cmd = compilecmd "/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}:read-resource()"
    res = executeAndGet cmd
    @data = res[:data]
    res
  end

  # Methods set attributes for messaging to default hornetq-server
  # @param {String} name a key for representing name.
  # @param {Object} value a value of attribute
  def setattr(name, value)
    setattribute_raw "/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}", name, value
  end
end
