# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss
# JBoss provider module
module Provider
# JBoss datasource provider module
module Datasource

# A class for JBoss post WildFly datasource provider
class PostWildFlyProvider
  def initialize(provider)
    @provider = provider
  end
  def xa_datasource_properties_wrapper(parameters)
    "{#{parameters}}"
  end

  def jta
    if @provider.xa?
      true.to_s
    else
      @provider.getattrib('jta').to_s
    end
  end

  def jta= value
    Puppet.warning 'JTA does not make sense in XA Datasource as distributed transaction is being used' if @provider.xa?
    @provider.setattrib('jta', value.to_s) unless @provider.xa?
  end

  def jta_opt(cmd)
    cmd.push "--jta=#{@provider.resource[:jta].inspect}" unless @provider.xa?
  end
end

end
end
end
end
end