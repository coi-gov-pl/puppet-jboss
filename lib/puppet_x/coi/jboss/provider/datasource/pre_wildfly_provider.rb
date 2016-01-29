# A class for JBoss pre WildFly datasource provider
class Puppet_X::Coi::Jboss::Provider::Datasource::PreWildFlyProvider
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
