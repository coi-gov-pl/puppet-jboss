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
