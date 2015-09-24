require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet_X::Coi::Jboss.requirex 'type/domain-controller-configurator'
Puppet_X::Coi::Jboss.requirex 'type/retry-configurator'

Puppet::Type.newtype(:jboss_deploy) do
  @doc = "Deploys and undeploys EAR/WAR artifacts on JBoss Application Server"
  ensurable

  newparam(:name) do
    desc "The JNDI resource name."
    isnamevar
    isrequired
  end

  newparam(:source) do
    desc "Path to the EAR/WAR file."
  end

  newparam(:redeploy, :boolean => true) do
    desc "Force redeployment"
    defaultto false
  end

  newproperty(:servergroups, :array_matching => :all) do
    desc "Array of server groups on which deployment should be done"
  end

  Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator.new(self).configure_without_profile
  Puppet_X::Coi::Jboss::Type::RetryConfigurator.new(self).configure
  
end
