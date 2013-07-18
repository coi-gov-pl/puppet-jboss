require 'puppet/provider/jbosscli'
Puppet::Type.type(:securitydomain).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  commands :jbosscli => "#{Puppet::Provider::Jbosscli.jbossclibin}"


  def create

    cmd = "/profile=default/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add(login-modules=[{code=>\"#{@resource[:code]}\",flag=>\"#{@resource[:codeflag]}\",module-options=>["

    #return execute(cmd)[:result]
    Puppet.debug("testing222222222222 " + cmd)
    @resource[:moduleoptions].each_with_index do |(key, value), index|
      puts "Key: #{key}"
      puts "Value: #{value}"
      puts "Index: #{index}"
      cmd += "#{key}=>\"#{value}\""
      if index == @resource[:moduleoptions].length - 1
        break
      end
      cmd += ","
    end
    cmd += "]}])"
    Puppet.debug("####################################" + cmd)
    execute("/profile=default/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)")[:result]
    return execute(cmd)[:result]
  end

  def destroy
    cmd = "/profile=default/subsystem=security/security-domain=#{@resource[:name]}:remove()"
    return execute(cmd)[:result]

    return false
  end

  #
  def exists?
    Puppet.debug("testing-21")
    #res = execute("xa-data-source --profile=#{@resource[:profile]} read-resource --name=#{@resource[:name]}")

    res = execute_datasource("/profile=default/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:read-resource()")
    #Puppet.debug("testing-22  "   + res[:data]["module-options"] )
    if res == false
      return false
    end

   #:moduleoptions
   #:code
   #:codeflag)
    #
    #
    #if !@resource[:jndiname].nil? && @resource[:jndiname] != res[:data]["jndi-name"] \
    #    || !@resource[:drivername].nil? && @resource[:drivername] != res[:data]["driver-name"] \
    #    || !@resource[:minpoolsize].nil? && @resource[:minpoolsize] != res[:data]["min-pool-size"] \
    #    || !@resource[:maxpoolsize].nil? && @resource[:maxpoolsize] != res[:data]["max-pool-size"] \
    #    || !@resource[:username].nil? && @resource[:username] != res[:data]["user-name"] \
    #    || !@resource[:password].nil? && @resource[:password] != res[:data]["password"] \
    #    || !@resource[:validateonmatch].nil? && @resource[:validateonmatch] != res[:data]["validate-on-match"] \
    #    || !@resource[:backgroundvalidation].nil? && @resource[:backgroundvalidation] != res[:data]["background-validation"] \
    #    || !@resource[:sharepreparestatements].nil? && @resource[:sharepreparestatements] != res[:data]["share-prepared-statements"] \
    #    || !@resource[:xadatasourceproperties].nil? && @resource[:xadatasourceproperties] != res[:data]["xa-datasource-properties"]
    #  Puppet.debug("security-domain configuration is different, updating security-domain: #{@resource[:name]}" + @resource[:name])
    #  destroy
    #  return false
    #end

    return true
  end
end
