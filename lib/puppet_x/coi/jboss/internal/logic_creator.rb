# Class that will decide what cammands should be send to cli to set up security domain
class Puppet_X::Coi::Jboss::Internal::LogicCreator
  # @param [Puppet_X::Coi::Jboss::Internal::JbossSecurityDomainState] state current state of
  # securitydomain configuration
  # @param [Puppet_X::Coi::Jboss::Provider::SecurityDomain::Provider] provider that indicates if
  # we need to use diffrent paths to setup securitydomain
  def initialize(auditor, resource, provider, compilator)
    @auditor = auditor
    @resource = resource
    @provider = provider
    @compilator = compilator
  end

  # Method that will return list of commands based on current state
  # @param {Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider| Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider}
  # @return [Hash] commands Hash with commands that will be executed, key is message that will
  # be displayed and value is command
  def decide
    state = @auditor.fetch_securtydomain_state
    commands = []
    unless state.cache_default?
      command = prepare_profile("/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)")
      commands.push(['Security Domain Cache Type', command])
    end
    unless state.is_authentication
      command = prepare_profile("/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add()")
      commands.push(['Security Domain Authentication', command])
    end
    unless state.is_login_modules
      cmd = @provider.make_command_templates
      command = prepare_profile(cmd)
      commands.push(['Security Domain Login Modules', command])
    end
    commands
  end

  private

  # Methods that compiles jboss command
  # @param {String} command jboss command that will be executed
  # @return {String} comamnd with profile if needed
  def prepare_profile(command)
    @compilator.compile(@resource[:runasdomain], @resource[:profile], command)
  end
end
