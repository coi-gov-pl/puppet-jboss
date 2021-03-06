# Class that handles removing securitydomain from jboss instance
class PuppetX::Coi::Jboss::Internal::SecurityDomainDestroyer
  # Standard constructor
  # @param {PuppetX::Coi::Jboss::Internal::CliExecutor} cli_executor executor that will handle
  # command execution
  # @param {PuppetX::Coi::Jboss::Internal::CommandCompilator} compilator handles compilation of
  # commands
  # @param {Hash} resource standard Puppet resource object
  def initialize(cli_executor, compilator, resource)
    @cli_executor = cli_executor
    @compilator = compilator
    @resource = resource
  end

  # Method that compiles jboss command and executes destroy command
  # @param {resource} resource standard Puppet resource
  def destroy(resource)
    Puppet.debug('Destroy method')
    compiled_cmd = @compilator.compile(
      @resource[:runasdomain],
      @resource[:profile],
      "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:remove()"
    )
    @cli_executor.execute_with_fail('SecurityDomain', compiled_cmd, 'to destroy', resource)
  end
end
