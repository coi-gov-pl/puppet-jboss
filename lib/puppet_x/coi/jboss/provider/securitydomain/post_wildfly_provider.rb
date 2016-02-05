# A class for JBoss post WildFly datasource provider
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider
  def initialize(provider)
    @provider = provider
  end

  def create_parametrized_cmd

    correct_cmd = "subsystem=security/security-domain=#{@provider.resource[:name]}/authentication=classic/login-module=" + 
    "UsersRoles:add(code=#{@provider.resource[:code]},flag=#{@provider.resource[:codeflag]},module-options=["
    options = []
    @provider.resource[:moduleoptions].keys.sort.each do |key|
      value = @provider.resource[:moduleoptions][key]
      val = value.to_s.gsub(/\n/, ' ').strip
      options << '(%s => %s)' % [key.inspect, val.inspect]
    end
    correct_cmd += options.join(',') + "]}])"
    correct_cmd
  end
end
