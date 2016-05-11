# Class that handles removing securitydomain from jboss instance
class Puppet_X::Coi::Jboss::Internal::SecurityDomainDestroyer
  # Standard constructor
  # @param {Puppet_X::Coi::Jboss::Internal::CliExecutor} cli_executor executor that will handle
  # command execution
  # @param {Puppet_X::Coi::Jboss::Internal::CommandCompilator} compilator handles compilation of
  # commands
  # @param {Hash} resource standard Puppet resource object
  def initialize(cli_executor, compilator, resource)
    @cli_executor = cli_executor
    @compilator = compilator
    @resource = resource
  end

  def destroy(resource)
    Puppet.debug('Destroy method')
    compiled_cmd = @compilator.compile(@resource[:runasdomain],
                                       @resource[:profile],
                                       "/subsystem=security/security-domain=#{@resource[:name]}:remove()")
    @cli_executor.executeWithFail('SecurityDomain', compiled_cmd, 'to destroy', resource)
  end
end
