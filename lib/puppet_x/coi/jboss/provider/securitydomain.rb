# A class for JBoss security domain provider
module Puppet_X::Coi::Jboss::Provider::SecurityDomain

  # Method that creates security-domain in Jboss instance. When invoked it will execute 3 commands, add cache-type with
  # value 'default', add authentication with value classic, add login-modules. Depends on the version of server it will
  # use correct path to set security domain
  def create
    commands = fetch_commands

    commands.each do |message, command|
      bringUp(message, command)
    end
  end

  # Method to remove security-domain from Jboss instance
  def destroy
    cmd = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:remove()"
    bringDown('Security Domain', cmd)[:result]
  end

  # Method to check if there is security domain. Method calls recursive read-resource on security subsystem to validate
  # if security domain is present. In the procces method also checks if authentication is set.
  def exists?

    cli_executor = ensure_cli_executor

    @auditor = Puppet_X::Coi::Jboss::Internal::SecurityDomainAuditor.new(@resource, cli_executor)

    @auditor.exists?
  end

  def execution_state_wrapper=(shell_executor)
    @cli_executor.shell_executor = shell_executor
  end

  private

  def ensure_cli_executor
      shell_executor = Puppet_X::Coi::Jboss::Internal::Executor::ShellExecutor.new
      execution_state_wrapper = Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper.new(shell_executor)
      @cli_executor = Puppet_X::Coi::Jboss::Internal::CliExecutor.new(execution_state_wrapper) if @cli_executor.nil?
      @cli_executor
  end

  def fetch_commands
    provider = provider_impl
    logic_creator = Puppet_X::Coi::Jboss::Internal::LogicCreator.new(@auditor, @resource, provider)
    logic_creator.decide
  end

  # Method that provides information about which command template should be user_id
  # @return {Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider|Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider} provider with correct command template
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
