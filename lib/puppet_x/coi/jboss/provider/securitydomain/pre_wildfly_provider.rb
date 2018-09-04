# A module for JBoss pre WildFly security domain provider
class PuppetX::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider <
  PuppetX::Coi::Jboss::Provider::SecurityDomain::AbstractProvider

  # This is a default constructor
  # @param {Hash} resource standard Puppet resource
  # @param {PuppetX::Coi::Jboss::Internal::CommandCompilator} compilator that is used to compile jboss command
  def initialize(resource, compilator)
    @resource = resource
    @compilator = compilator
  end

  protected

  #  Method that hold first part of securitydomain jboss command
  # @param {Hash} resource standard Puppet resource
  # @return {String} begining security-domain command
  def correct_command_template_begining(resource)
    "/subsystem=security/security-domain=#{resource[:name]}/authentication=classic:add(login-modules=[{code=>#{resource[:code].inspect},flag=>#{resource[:codeflag].inspect},module-options=>["
  end

  # Method that holds end of security-domain jboss command
  # @return {String} ending of security-domain jboss command
  def correct_command_template_ending
    ']}])'
  end

  # Method that holds template for module options in security-domain
  # @return {String} template
  def module_option_template
    '%s=>%s'
  end

  # Method that decides what commands should be added to command execution list
  # @param {Hash} resource standard Puppet resource
  # @param {PuppetX::Coi::Jboss::Internal::State::SecurityDomainState} state that holds informations about current state of security domain
  # @return {List} commands
  def decide(resource, state)
    unless everything_is_set?(state)
      commands = []
      main_cmd = build_main_command
      command = compile_command(main_cmd, resource)
      commands.push(['Security Domain Login Modules', command])
    end
  end

  # Method that return boolean value if everything in security domain in set
  # @param {PuppetX::Coi::Jboss::Internal::State::SecurityDomainState} state that holds informations about current state of security domain
  # @return {Boolean}
  def everything_is_set?(state)
    state.is_authentication && state.is_login_modules
  end
end
