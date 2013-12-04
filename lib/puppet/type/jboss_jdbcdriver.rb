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
    isrequired
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
      else
        super
      end
    end
  end

end
