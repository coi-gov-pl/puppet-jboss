Puppet::Type.newtype(:jboss_confignode) do
  @doc = "Generic configuration entry for JBoss Application Sever"
  ensurable
  
  newparam(:name) do
    desc "The name of resource"
  end
  
  newparam(:path) do
    desc "The JBoss configuration path to be ensured"
  end
  
  newproperty(:properties) do 
    desc "Additional properties for node"
    defaultto {}
  end

  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full-ha"
  end

  newparam(:runasdomain, :boolean => true) do
    desc "Indicate that server is in domain mode"
    newvalues :true, :false
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