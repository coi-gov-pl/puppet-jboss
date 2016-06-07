# A class for JBoss security domain provider
module Puppet_X::Coi::Jboss::Provider::SecurityDomain
  # Method to check if there is security domain. Method calls recursive read-resource on security
  # subsystem to validate
  # if security domain is present. In the procces method also checks if authentication is set.
  def exists?
    auditor = ensure_auditor
    auditor.exists?
  end

  # Method that creates security-domain in Jboss instance. When invoked it will execute 3 commands,
  # add cache-type with value 'default', add authentication with value classic, add login-modules.
  # Depends on the version of server it will use correct path to set security domain
  def create
    commands = fetch_commands
    Puppet.debug("Commands: #{commands}")
    
    commands.each do |message, command|
      bringUp(message, command)
    end
  end

  # Method to remove security-domain from Jboss instance
  def destroy
    destroyer = ensure_destroyer
    destroyer.destroy(@resource)[:result]
  end

  private

  def ensure_destroyer
    cli_executor = ensure_cli_executor
    @secdom_destroyer = Puppet_X::Coi::Jboss::Internal::SecurityDomainDestroyer.new(cli_executor,
                                                                                    @compilator,
                                                                                    @resource) if @secdom_destroyer.nil?
    @secdom_destroyer
  end

  def ensure_auditor
    destroyer = ensure_destroyer
    cli_executor = ensure_cli_executor
    @auditor = Puppet_X::Coi::Jboss::Internal::SecurityDomainAuditor.new(@resource,
                                                                         cli_executor,
                                                                         @compilator,
                                                                         destroyer) if @auditor.nil?
    @auditor
  end

  def fetch_commands
    Puppet.debug('Fetch commands')
    auditor = ensure_auditor
    provider = provider_impl
    logic_creator = Puppet_X::Coi::Jboss::Internal::LogicCreator.new(auditor, @resource, provider)
    logic_creator.decide
  end

  # Method that provides information about which command template should be user_id
  # @return {Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider|
  # Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider}
  # provider with correct command template
  def provider_impl
    require_relative 'securitydomain/pre_wildfly_provider'
    require_relative 'securitydomain/post_wildfly_provider'

    if @impl.nil?
      if Puppet_X::Coi::Jboss::Configuration::is_pre_wildfly?
        @impl = Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider.new(@resource)
      else
        @impl = Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider.new(@resource)
      end
    end
    @impl
  end
end
