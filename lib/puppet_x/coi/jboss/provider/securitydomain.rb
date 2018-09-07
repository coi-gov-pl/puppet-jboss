# A class for JBoss security domain provider
module PuppetX::Coi::Jboss::Provider::SecurityDomain
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

  # Method that ensures that destroyer is present in the system, if not it creates one
  # @return {PuppetX::Coi::Jboss::Internal::SecurityDomainDestroyer} destroyer
  def ensure_destroyer
    cli_executor = ensure_cli_executor
    @secdom_destroyer = PuppetX::Coi::Jboss::Internal::SecurityDomainDestroyer.new(cli_executor,
                                                                                    @compilator,
                                                                                    @resource) if @secdom_destroyer.nil?
    @secdom_destroyer
  end

  # Method that ensures that auditor is present in the system, if not it creates one
  # @return {PuppetX::Coi::Jboss::Internal::SecurityDomainAuditor} auditor
  def ensure_auditor
    destroyer = ensure_destroyer
    cli_executor = ensure_cli_executor
    @auditor = PuppetX::Coi::Jboss::Internal::SecurityDomainAuditor.new(@resource,
                                                                         cli_executor,
                                                                         @compilator,
                                                                         destroyer) if @auditor.nil?
    @auditor
  end

  # Method that fetches commands that need to be executed to setup security-domain
  # @return {List} commands list of commands that are going to be executed
  def fetch_commands
    auditor = ensure_auditor
    provider = provider_impl
    logic_creator = PuppetX::Coi::Jboss::Internal::LogicCreator.new(auditor, @resource, provider, @compilator)
    logic_creator.decide
  end

  # Method that provides information about which command template should be used
  # @return {PuppetX::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider|
  # PuppetX::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider}
  # provider with correct command template
  def provider_impl
    require_relative 'securitydomain/pre_wildfly_provider'
    require_relative 'securitydomain/post_wildfly_provider'

    if @impl.nil?
      if PuppetX::Coi::Jboss::Configuration.pre_wildfly?
        @impl = PuppetX::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider.new(@resource, @compilator)
      else
        @impl = PuppetX::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider.new(@resource, @compilator)
      end
    end
    @impl
  end
end
