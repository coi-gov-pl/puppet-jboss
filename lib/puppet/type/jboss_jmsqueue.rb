Puppet::Type.newtype(:jboss_jmsqueue) do
  @doc = "JMS Queues configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc "name"
    isnamevar
  end

  newproperty(:entries, :array_matching => :all) do
    desc "entries passed as array"
  end

  newproperty(:durable, :boolean => true) do
    newvalues :true, :false
    defaultto false
    desc "durable true/false"
  end
    
  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full"
  end

  newparam(:runasdomain, :boolean => true) do
    desc "Indicate that server is in domain mode"
    defaultto true
  end
  
  newparam(:controller) do
    desc "Domain controller host:port address"
    defaultto "localhost:9999"
    validate do |value|
      if value == nil and @resource[:runasdomain]
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
