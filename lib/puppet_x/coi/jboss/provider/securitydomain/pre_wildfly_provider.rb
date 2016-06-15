# A module for JBoss pre WildFly security domain provider
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider <
  Puppet_X::Coi::Jboss::Provider::SecurityDomain::AbstractProvider
  # This is a default constructor
  # @param {Puppet_X::Coi::Jboss::Provider::SecurityDomain} provider a security domain provider
  def initialize(resource, compilator)
    @resource = resource
    @compilator = compilator
  end

  protected

  def correct_command_template_begining(resource)
    "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:add(login-modules=[{code=>#{resource[:code].inspect},flag=>#{resource[:codeflag].inspect},module-options=>["
  end

  def correct_command_template_ending
    ']}])'
  end

  def module_option_template
    '%s=>%s'
  end

  def decide(resource, state)
    binding.pry
    unless (state.is_authentication && state.is_login_modules)
      commands = []
      cmd = make_command_templates
      command = prepare_profile(cmd, resource)
      commands.push(['Security Domain Login Modules', command])
    end
  end
end
