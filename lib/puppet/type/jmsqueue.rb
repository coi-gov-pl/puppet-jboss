Puppet::Type.newtype(:jmsqueue) do
  @doc = "JMS Queues configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc "name"
    isnamevar
  end

  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full"
  end

  newparam(:entries) do
    desc "entries separeted with comma"
  end

  newparam(:durable) do
    desc "durable true/false"
  end
    
  newparam(:runasdomain) do
    desc "Run server in domain mode"
    defaultto true
  end

end
