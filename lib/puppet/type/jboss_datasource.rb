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
      absentlike = [:absent, :undef, nil]
      absentlike.concat(absentlike.map {|v| v.to_s})
      hashlike = (value.respond_to? :[] and value.respond_to? :each and not value.is_a? String and not value.is_a? Symbol)
      unless absentlike.include?(value) or hashlike
        fail "You can pass only hash-like objects or absent and undef values, given #{value.inspect}"
      end
    end

    munge do |value|
      if %w{absent undef}.include?(value) then value.to_sym else value end
    end

    def change_to_s(current, desire)
      changes = []
      absentlike = [:absent, :undef, nil]
      absentlike.concat(absentlike.map {|v| v.to_s})
      keys = []
      keys.concat(desire.keys) unless absentlike.include?(desire)
      keys.concat(current.keys) unless absentlike.include?(current)
      keys.uniq.sort.each do |key|
        desired_value = if absentlike.include?(desire) then desire else desire[key] end
        current_value = if absentlike.include?(current) then current else current[key] end
        if absentlike.include?(desired_value) and not absentlike.include?(current_value) then
          message = "option '#{key}' was #{current_value.inspect} and has been removed"
        elsif absentlike.include?(current_value) and not absentlike.include?(desired_value)
          message = "option '#{key}' has been set to #{desired_value.inspect}"
        else
          message = "option '#{key}' has changed from #{current_value.inspect} to #{desired_value.inspect}"
        end
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
      # Regex developed here (hostnames, ipv4, ipv6): https://regex101.com/r/hJ4jD1/3
      re = /^((?:[a-zA-Z0-9_-]+\.)*[a-zA-Z0-9_-]+|(?:[a-fA-F0-9]{0,4}:){2,5}[a-fA-F0-9]{1,4})$/
      unless value == '' or re.match(value.to_s)
        raise ArgumentError, "Datasource host is invalid, given #{value.inspect}"
      end
    end
  end
  
  newproperty(:port) do
    desc "port to connect"
    isrequired
    validate do |value|
      unless value == '' or /^\d+$/.match(value.to_s)
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

