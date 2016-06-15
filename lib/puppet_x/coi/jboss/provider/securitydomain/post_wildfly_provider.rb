# A module for JBoss post WildFly security domain resource that provides command to be executed
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider <
  Puppet_X::Coi::Jboss::Provider::SecurityDomain::AbstractProvider
  # This is a default constructor
  # @param {Puppet_X::Coi::Jboss::Provider::SecurityDomain} resource a security domain resource
  def initialize(resource, compilator)
    @resource = resource
    @compilator = compilator
  end

  protected

  def correct_command_template_begining(resource)
    "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic/login-module=#{resource[:name]}:add" +
    "(code=#{resource[:code].inspect},flag=#{resource[:codeflag].inspect},module-options=["
  end

  def correct_command_template_ending
    '])'
  end

  def module_option_template
    '(%s=>%s)'
  end

  def decide(resource, state)
    commands = []
    unless state.is_authentication
      command = prepare_profile("/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:add()", resource)
      commands.push(['Security Domain Authentication', command])
    end
    unless state.is_login_modules
      cmd = make_command_templates
      command = prepare_profile(cmd, resource)
      commands.push(['Security Domain Login Modules', command])
    end
    commands
  end
end
