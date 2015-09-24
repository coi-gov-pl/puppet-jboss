require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet_X::Coi::Jboss.requirex 'type/domain-controller-configurator'
Puppet_X::Coi::Jboss.requirex 'type/retry-configurator'

Puppet::Type.newtype(:jboss_resourceadapter) do
  @doc = "Manages resource adapters on JBoss Application Server"
  ensurable

  newparam(:name) do
    desc "The name/ID of resource adapter."
    isnamevar
    isrequired
  end
  
  newproperty(:archive) do
    desc "The resource adapter archive."
    isrequired
  end

  newproperty(:transactionsupport) do
    desc "The resource adapter transaction support type."
    isrequired
  end
  
  newproperty(:jndiname, :array_matching => :all) do
    desc "The resource adapter connection definition jndi name."
    isrequired
  end
  
  newproperty(:classname) do
    desc "The resource adapter connection definition class name."
    isrequired
  end
  
  newproperty(:security) do 
    desc "The resource adapter connection definition security."
    isrequired
    defaultto 'application'
  end
  
  newproperty(:backgroundvalidation, :boolean => true) do
    desc "The resource adapter connection definition class name."
    isrequired
    defaultto true
  end

  Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator.new(self).configure
  Puppet_X::Coi::Jboss::Type::RetryConfigurator.new(self).configure

end
