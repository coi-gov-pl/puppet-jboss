require 'puppet/provider/jbosscli'
Puppet::Type.type(:datasource).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  commands :jbosscli => "#{Puppet::Provider::Jbosscli.jbossclibin}"


  def create
    cmd = "xa-data-source --profile=#{@resource[:profile]} add --name=#{@resource[:name]} --jndi-name=#{@resource[:jndiname]} --driver-name=#{@resource[:drivername]} --min-pool-size=#{@resource[:minpoolsize]} --max-pool-size=#{@resource[:maxpoolsize]} --user-name=#{@resource[:username]} --password=#{@resource[:password]} --validate-on-match=#{@resource[:validateonmatch]} --background-validation=#{@resource[:backgroundvalidation]} --share-prepared-statements=#{@resource[:sharepreparestatements]} --xa-datasource-properties=Url=#{@resource[:xadatasourceproperties]},"
    return execute(cmd)[:result]
  end

  def destroy
    cmd = "xa-data-source --profile=#{@resource[:profile]} remove --name=#{@resource[:name]}"
    return execute(cmd)[:result]
  end

  #
  def exists?

    Puppet.debug("testing-12")
    #res = execute("xa-data-source --profile=#{@resource[:profile]} read-resource --name=#{@resource[:name]}")

    res = execute_datasource("/profile=#{@resource[:profile]}/subsystem=datasources/xa-data-source=#{@resource[:name]}:read-resource()")
    Puppet.debug("testing-13  "   + res.to_s )
    if res == false
      return false
    end

    if !@resource[:jndiname].nil? && @resource[:jndiname] != res[:data]["jndi-name"] \
        || !@resource[:drivername].nil? && @resource[:drivername] != res[:data]["driver-name"] \
        || !@resource[:minpoolsize].nil? && @resource[:minpoolsize] != res[:data]["min-pool-size"] \
        || !@resource[:maxpoolsize].nil? && @resource[:maxpoolsize] != res[:data]["max-pool-size"] \
        || !@resource[:username].nil? && @resource[:username] != res[:data]["user-name"] \
        || !@resource[:password].nil? && @resource[:password] != res[:data]["password"] \
        || !@resource[:validateonmatch].nil? && @resource[:validateonmatch] != res[:data]["validate-on-match"] \
        || !@resource[:backgroundvalidation].nil? && @resource[:backgroundvalidation] != res[:data]["background-validation"] \
        || !@resource[:sharepreparestatements].nil? && @resource[:sharepreparestatements] != res[:data]["share-prepared-statements"] \
        || !@resource[:xadatasourceproperties].nil? && @resource[:xadatasourceproperties] != res[:data]["xa-datasource-properties"]
      Puppet.debug("xa-data-source configuration is different, updating xa-data-source: #{@resource[:name]}" + @resource[:name])
      destroy
      return false
    end

    return true

    #for line in res[:lines]
    #  line.strip!
    #  Puppet.debug("testing-14a: " + line)
    #if line == self.basename
    #  return true
    #end
    #end
    #return false
  end
#
end
