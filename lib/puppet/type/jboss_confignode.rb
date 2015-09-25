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
  
  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full"
  end

  newparam(:runasdomain, :boolean => true) do
    desc "Indicate that server is in domain mode"
    newvalues :true, :false
    defaultto :true
    
    munge do |val|
      val == :true or val == true
    end
  end
  
  newparam(:controller) do
    desc "Domain controller host:port address"
    validate do |value|
      if value == nil or value.to_s == 'undef'
        raise ArgumentError, "Domain controller must be provided"
      end
    end
  end
  
  newparam :ctrluser do
    desc 'A user name to connect to controller'
  end

  newparam :ctrlpasswd do
    desc 'A password to be used to connect to controller'
  end

  newparam :retry do
    desc "Number of retries."
    defaultto 3
  end

  newparam :retry_timeout do
    desc "Retry timeout in seconds"
    defaultto 1
  end
  
  
end