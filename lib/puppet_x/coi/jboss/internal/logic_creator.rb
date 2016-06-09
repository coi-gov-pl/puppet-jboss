# Class that will decide what cammands should be send to cli to set up security domain
class Puppet_X::Coi::Jboss::Internal::LogicCreator
  # @param [Puppet_X::Coi::Jboss::Internal::JbossSecurityDomainState] state current state of
  # securitydomain configuration
  # @param [Puppet_X::Coi::Jboss::Provider::SecurityDomain::Provider] provider that indicates if
  # we need to use diffrent paths to setup securitydomain
  def initialize(auditor, resource, provider)
    @auditor = auditor
    @resource = resource
    @provider = provider
  end

  # Method that will return list of commands based on current state
  # @param {Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider| Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider}
  # @return [Hash] commands Hash with commands that will be executed, key is message that will
  # be displayed and value is command
  def decide
    state = @auditor.fetch_securtydomain_state
    Puppet.debug("State: #{state.cache_default?}")
    Puppet.debug("State: #{state.is_authentication}")
    Puppet.debug("State: #{state.is_login_modules}")
    commands = []
    unless state.cache_default?
      commands.push(['Security Domain Cache Type', "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)"])
    end
    unless state.is_authentication
      commands.push(['Security Domain Authentication', "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add()"])
    end
    unless state.is_login_modules
      cmd = @provider.make_command_templates
      commands.push(['Security Domain Login Modules', cmd])
    end
    commands
  end
end
