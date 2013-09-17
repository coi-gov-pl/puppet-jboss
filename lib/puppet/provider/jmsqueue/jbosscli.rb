require 'puppet/provider/jbosscli'

Puppet::Type.type(:jmsqueue).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  def create
    cmd = "jms-queue --profile=#{@resource[:profile]} add --queue-address=#{@resource[:name]} --entries=["
    @resource[:entries].each_with_index {|value, index|
      cmd += "\"#{value}\""
      if index == @resource[:entries].length - 1
      break
      end
      cmd += ","
    }
    cmd += "]"
    return execute(cmd)[:result]
  end

  def destroy
    cmd = "jms-queue --profile=#{@resource[:profile]} remove --queue-address=#{@resource[:name]}"
    return execute(cmd)[:result]
  end

  #
  def exists?
    res = execute_datasource("/profile=#{@resource[:profile]}/subsystem=messaging/hornetq-server=default/jms-queue=#{@resource[:name]}:read-resource")

    if res == false
    return false
    end

    if !@resource[:entries].nil? && !res[:data]["entries"].nil? && res[:data]["entries"] != @resource[:entries]
      destroy
    return false
    end

    return true
  end
end
