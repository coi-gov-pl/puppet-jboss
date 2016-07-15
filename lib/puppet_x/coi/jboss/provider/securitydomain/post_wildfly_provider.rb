# A module for JBoss post WildFly security domain resource that provides command to be executed
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider <
  Puppet_X::Coi::Jboss::Provider::SecurityDomain::AbstractProvider

  # This is a default constructor
  # @param {Hash} resource standard Puppet resource
  # @param {Puppet_X::Coi::Jboss::Internal::CommandCompilator} compilator that is used to compile jboss command
  def initialize(resource, compilator)
    @resource = resource
    @compilator = compilator
  end

  protected

  #  Method that hold first part of securitydomain jboss command
  # @param {Hash} resource standard Puppet resource
  # @return {String} begining security-domain command
  def correct_command_template_begining(resource)
    "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic/login-module=#{resource[:name]}:add" +
    "(code=#{resource[:code].inspect},flag=#{resource[:codeflag].inspect},module-options=["
  end

  # Method that holds end of security-domain jboss command
  # @return {String} ending of security-domain jboss command
  def correct_command_template_ending
    '])'
  end

  # Method that holds template for module options in security-domain
  # @return {String} template
  def module_option_template
    '(%s=>%s)'
  end

  # Method that decides what commands should be added to command execution list
  # @param {Hash} resource standard Puppet resource
  # @param {Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState} state that holds informations about current state of security domain
  # @return {List} commands
  def decide(resource, state)
    commands = []
    unless state.is_authentication
      command = compile_command("/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:add()", resource)
      commands.push(['Security Domain Authentication', command])
    end
    unless state.is_login_modules
      main_cmd = build_main_command
      command = compile_command(main_cmd, resource)
      commands.push(['Security Domain Login Modules', command])
    end
    commands
  end
end
