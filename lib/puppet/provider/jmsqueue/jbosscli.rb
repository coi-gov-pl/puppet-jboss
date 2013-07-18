require 'puppet/provider/jbosscli'
Puppet::Type.type(:jmsqueue).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  commands :jbosscli => "#{Puppet::Provider::Jbosscli.jbossclibin}"


  def create
    cmd = "jms-queue --profile=#{@resource[:profile]} add --queue-address=#{@resource[:name]} --entries=[#{@resource[:entries]}]"
    return execute(cmd)[:result]
  end

  def destroy
    cmd = "jms-queue --profile=#{@resource[:profile]} remove --queue-address=#{@resource[:name]}"
    return execute(cmd)[:result]
  end

  #
  def exists?
    Puppet.debug("testing2")

    res = execute_datasource("/profile=#{@resource[:profile]}/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}:read-resource")
    Puppet.debug("testing3  "   + res.to_s )
    #Puppet.debug("testing4  " + res[:data]["entries"].to_s)

    if res == false
      return false
    end

    return true
  end
end
