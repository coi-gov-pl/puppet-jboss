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
    newvalues :true, :false
    defaultto :true
    munge do |value|
      value == :true or value == true
    end
  end

  newproperty(:drivername) do
    desc "driver-name"
    isrequired
  end

  newproperty(:minpoolsize) do
    desc "min-pool-size"
    munge do |value|
      value.to_i if Float value rescue 1
    end
  end

  newproperty(:maxpoolsize) do
    desc "max-pool-size"
    munge do |value|
      value.to_i if Float value rescue 50
    end
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

  newproperty(:options) do
    desc "Extra options for datasource or xa-datasource"
    
    validate do |value|
      unless value.respond_to? :[]
        fail "You can pass only hash-like objects"
      end
    end
    
    def change_to_s(current, desire)
      changes = []
      desire.each do |key, desired_value|
        current_value = current[key]
        message = "option '#{key}' has changed from #{current_value.inspect} to #{desired_value.inspect}"
        changes << message unless current_value == desired_value   
      end
      changes.join ', '
    end
  end
  
  newproperty(:enabled) do
    desc "Is datasource enabled?"
    newvalues :true, :false
    defaultto :true
    munge do |value|
      value == :true or value == true
    end
  end

  newproperty(:host) do
    desc "host to connect"
    isrequired
    validate do |value|
      unless value =~ /\w/ or value == ''
        raise ArgumentError, "Datasource host is invalid, given #{value.inspect}"
      end
    end
  end
  
  newproperty(:port) do
    desc "port to connect"
    isrequired
    validate do |value|
      unless value =~ /\d/ or value == ''
        raise ArgumentError, "Datasource port is invalid, given #{value.inspect}"
      end
    end    
    munge do |value|
      if value == '' then 0 else Integer(value) end      
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
    # Default is set to support listing of datasources without parameters (for easy use)
    defaultto "127.0.0.1:9990"
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

