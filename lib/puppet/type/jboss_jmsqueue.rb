require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet_X::Coi::Jboss.requirex 'type/domain-controller-configurator'
Puppet_X::Coi::Jboss.requirex 'type/retry-configurator'

Puppet::Type.newtype(:jboss_jmsqueue) do
  @doc = "JMS Queues configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc "name"
    isnamevar
  end

  newproperty(:entries, :array_matching => :all) do
    desc "entries passed as array"
    
    def is_to_s is
      return is.inspect
    end
    def should_to_s should
      return should.inspect
    end
  end

  newproperty(:durable, :boolean => true) do
    newvalues :true, :false
    defaultto false
    desc "durable true/false"
  end

  Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator.new(self).configure
  Puppet_X::Coi::Jboss::Type::RetryConfigurator.new(self).configure

end
