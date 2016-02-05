# A class for JBoss pre WildFly securitydomain provider
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider
  def initialize(provider)
    @provider = provider
  end

  def create_parametrized_cmd
    cmd = "/subsystem=security/security-domain=#{@provider.resource[:name]}/authentication=classic:add(login-modules=[{code=>\"#{@provider.resource[:code]}\",flag=>\"#{@provider.resource[:codeflag]}\",module-options=>["
    options = []
    @provider.resource[:moduleoptions].keys.sort.each do |key|
      value = @provider.resource[:moduleoptions][key]
      val = value.to_s.gsub(/\n/, ' ').strip
      options << '%s => "%s"' % [key, val]
    end
    cmd += options.join(',') + "]}])"
    cmd
  end
end
