require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet_X::Coi::Jboss.requirex 'type/domain-controller-configurator'
Puppet_X::Coi::Jboss.requirex 'type/retry-configurator'

Puppet::Type.newtype(:jboss_jdbcdriver) do
  @doc = "Manages JDBC driver on JBoss Application Server"
  ensurable

  newparam(:name) do
    desc "The name of driver."
    isnamevar
    isrequired
  end

  newparam(:modulename) do
    desc "Driver module name."
    isrequired
  end

  newparam(:classname) do
    desc "Driver Java class name."
  end
  
  newparam(:datasourceclassname) do
    desc "Datasource Java class name."
  end

  newparam(:xadatasourceclassname) do
    desc "XA Datasource Java class name."
  end

  Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator.new(self).configure
  Puppet_X::Coi::Jboss::Type::RetryConfigurator.new(self).configure
end
