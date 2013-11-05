Puppet::Type.newtype(:jboss_datasource) do
  @doc = "Data sources configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc "Name of type resource"
    isnamevar
  end
  
  newproperty(:jndiname) do
    desc "jndi-name"
  end
  
  newproperty(:jta) do
    desc "jta"
    newvalues(true, false)
    defaultto true
  end

  newproperty(:drivername) do
    desc "driver-name"
    isrequired
  end

  newproperty(:minpoolsize) do
    desc "min-pool-size"
    defaultto 1
  end

  newproperty(:maxpoolsize) do
    desc "max-pool-size"
    defaultto 50
  end

  newproperty(:username) do
    desc "user-name"
    isrequired
  end

  newproperty(:password) do
    desc "The internal JBoss user asadmin uses. Default: admin"
    isrequired
  end

  newproperty(:validateonmatch) do
    desc "validate-on-match"
    newvalues(true, false)
    defaultto false
  end

  newproperty(:backgroundvalidation) do
    desc "background-validation"
  end

  newproperty(:sharepreparedstatements) do
    desc "share-prepared-statements"
    newvalues(true, false)
    defaultto false
  end
  
  newproperty(:enabled) do
    desc "Is datasource enabled?"
    newvalues(true, false)
    defaultto true
  end

  newproperty(:xadatasourceproperties) do
    desc "xa-datasource-properties=URL"
    isrequired
    validate do |value|
      unless value =~ /\w:\d/
        raise ArgumentError, "Datasource URL (xadatasourceproperties) must be provided (host:port)"
      else
        super
      end
    end
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

