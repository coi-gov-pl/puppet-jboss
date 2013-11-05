Puppet::Type.newtype(:jboss_jmsqueue) do
  @doc = "JMS Queues configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc "name"
    isnamevar
  end

  newparam(:entries) do
    desc "entries separeted with comma"
  end

  newparam(:durable) do
    desc "durable true/false"
  end
    
  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full-ha"
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
      else
        super
      end
    end
  end

end
