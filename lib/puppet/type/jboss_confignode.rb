require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet_X::Coi::Jboss.requirex 'type/domain-controller-configurator'
Puppet_X::Coi::Jboss.requirex 'type/retry-configurator'

Puppet::Type.newtype(:jboss_confignode) do
  @doc = "Generic configuration entry for JBoss Application Sever"
  
  newproperty(:ensure) do
    desc "Whether a configuration node should be in one of `present`, `absent`, `running`, `stopped`, `disabled` or `enabled` state."

    newvalues :stopped, :running, :present, :absent, :enabled, :disabled

    aliasvalue(:true, :present)
    aliasvalue(:false, :absent)

  end  
  newparam(:name) do
    desc "The name of resource"
  end
  
  newparam(:path) do
    desc "The JBoss configuration path to be ensured"
  end
  
  newproperty(:properties) do 
    desc "Additional properties for node"

    munge do |value|
      unless value.respond_to? :[]
        {}
      else
        value
      end
    end
    
    def change_to_s(current, desire)
      changes = []
      desire.each do |key, desired_value|
        current_value = current[key]
        message = "property '#{key}' has been changed from #{current_value.inspect} to #{desired_value.inspect}"
        changes << message unless current_value == desired_value   
      end
      changes.join ', '
    end
  end
  
  Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator.new(self).configure
  Puppet_X::Coi::Jboss::Type::RetryConfigurator.new(self).configure  
end