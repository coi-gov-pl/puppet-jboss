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
      command = @compilator.compile(@resource[:runasdomain],
                                    @resource[:profile], "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)")

      commands.push(['Security Domain Cache Type', command])
    end
    provided_commands = @provider.get_commands(state, @resource)
    provided_commands = [] if provided_commands.nil?
    commands + provided_commands
  end

end
