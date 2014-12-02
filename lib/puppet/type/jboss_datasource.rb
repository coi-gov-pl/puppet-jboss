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
    defaultto :false    
    munge do |value|
      value == :true or value == true 
    end 
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

  newproperty(:newconnectionsql) do
    desc "new-connection-sql"
  end

  newproperty(:validateonmatch) do
    desc "validate-on-match"
    newvalues(true, false)
    defaultto false
  end

  newproperty(:backgroundvalidation) do
    desc "background-validation"
  end

  newproperty :preparedstatementscachesize do
    desc "Number of prepared statements per connection to be kept open and reused in subsequent requests. They are stored in a LRU cache."
    validate do |value|
      unless value.to_s =~ /(0|[1-9]\d*)/
        raise ArgumentError, "Non-numeric value of prepared statement cache size (#{value})"
      else
        super
      end
    end
    defaultto 0
  end

  newproperty :sharepreparedstatements do
    desc "With prepared statement cache enabled whether two requests in the same transaction should return the same statement"
    newvalues true, false
    defaultto false
  end
  
  newproperty :useccm do
    desc "Whether data source should use Cached Connection Manager (provides a debugging capability for leaked database connections - Unless you are doing your own JDBC code, this is typically not needed)"
    newvalues true, false
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
    munge do |value|
      Integer(value)      
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
  
  
  newparam :sharepreparedstmtcache do
    defaultto false
  end

end

