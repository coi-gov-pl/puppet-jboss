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

    system_runner = ensure_system_executor

    @auditor = Puppet_X::Coi::Jboss::Internal::JbossSecurityDomainAuditor.new(@resource, system_runner)

    @auditor.exists?
  end

  private
  def system_executor=(new_system_executor)
    before = @system_executor
    @system_executor = new_system_executor
    before
  end

  def system_executor
    @system_executor
  end

  def ensure_system_executor
      system_command_executor = Puppet_X::Coi::Jboss::Internal::Executor::JbossCommandExecutor.new
      system_runner = Puppet_X::Coi::Jboss::Internal::JbossSystemRunner.new(system_command_executor)
      @system_executor = Puppet_X::Coi::Jboss::Internal::JbossRunner.new(system_runner) if @system_executor.nil?
      @system_executor
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
