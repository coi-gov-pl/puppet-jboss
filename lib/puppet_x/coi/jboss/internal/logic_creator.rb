# Class that will decide what cammands should be send to cli to set up security domain
class Puppet_X::Coi::Jboss::Internal::LogicCreator

  # @param [Puppet_X::Coi::Jboss::Internal::JbossSecurityDomainState] state current state of securitydomain configuration
  # @param [Puppet_X::Coi::Jboss::Provider::SecurityDomain::Provider] provider that indicates if we need to use diffrent paths to setup securitydomain
  def initialize(auditor, resource, provider)
    @auditor = auditor
    @resource = resource
    @provider = provider
  end

  # Method that will return list of commands based on current state
  # @return [Hash] commands Hash with commands that will be executed, key is message that will be displayed and value is command
  def decide
    state = @auditor.fetch_securtydomain_state
    commands = []
    if not state.cache_default?

      commands.push(['Security Domain Cache Type', "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)"])
    end
    if not state.is_authentication
      commands.push(['Security Domain Authentication', "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add()"])
    end
    if not state.is_login_modules
      cmd = @provider.make_command_templates
      commands.push(['Security Domain Login Modules', cmd])
    end

    commands
  end
end
