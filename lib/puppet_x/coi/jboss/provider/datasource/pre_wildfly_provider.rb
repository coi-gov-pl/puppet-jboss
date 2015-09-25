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

# A class for JBoss pre WildFly datasource provider
class PreWildFlyProvider
  def initialize(provider)
    @provider = provider
  end

  def xa_datasource_properties_wrapper(parameters)
    "[#{parameters}]"
  end

  def jta
    @provider.getattrib('jta').to_s
  end

  def jta=(value)
    @provider.setattrib('jta', value.to_s)
  end

  def jta_opt(cmd)
    cmd.push "--jta=#{@provider.resource[:jta].inspect}"
  end
end

end
end
end
end
end