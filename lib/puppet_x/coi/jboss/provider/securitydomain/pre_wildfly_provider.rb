# A module for JBoss pre WildFly security domain provider
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider <
  Puppet_X::Coi::Jboss::Provider::SecurityDomain::AbstractProvider
  # This is a default constructor
  # @param {Puppet_X::Coi::Jboss::Provider::SecurityDomain} provider a security domain provider
  def initialize(provider)
    @provider = provider
  end

  protected

  def correct_command_template_begining(resource)
    "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:" +
    "add(login-modules=[{code=>#{resource[:code].inspect},flag=>#{resource[:codeflag].inspect},module-options=>["
  end

  def correct_command_template_ending
    ']}])'
  end

  def module_option_template
    '%s=>%s'
  end
end
