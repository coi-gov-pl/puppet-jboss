Puppet::Type.newtype(:jboss_datasource) do
  @doc = "Data sources configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc "Name of type resource"
    isnamevar
  end
  
  newproperty(:xa) do
    desc "Is it XA Datasource?"
    newvalues :true, :false
    defaultto false
  end
  
  newproperty(:dbname) do
    desc "The database's name"
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
    def change_to_s from, to
      "password has been changed."
    end
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
  
  newproperty(:samermoverride) do
    desc "same-rm-override"
    newvalues(true, false)
    defaultto true
  end
  
  newproperty(:wrapxaresource) do
    desc "wrap-xa-resource"
    newvalues(true, false)
    defaultto true
  end
  
  newproperty(:enabled) do
    desc "Is datasource enabled?"
    newvalues(true, false)
    defaultto true
  end

  newproperty(:host) do
    desc "host to connect"
    isrequired
    validate do |value|
      unless value =~ /\w/
        raise ArgumentError, "Datasource host is invalid"
      else
        super
      end
    end
  end
  
  newproperty(:port) do
    desc "port to connect"
    isrequired
    validate do |value|
      unless value =~ /\d/
        raise ArgumentError, "Datasource port is invalid"
      else
        super
      end
    end
  end
  
  newproperty(:jdbcscheme) do
    desc "jdbcscheme to be used"
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
  
  newparam :retry do
    desc "Number of retries."
    defaultto 3
  end

  newparam :retry_timeout do
    desc "Retry timeout in seconds"
    defaultto 1
  end
  
end

