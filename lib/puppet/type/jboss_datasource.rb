require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet_X::Coi::Jboss.requirex 'type/domain-controller-configurator'
Puppet_X::Coi::Jboss.requirex 'type/retry-configurator'

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
      unless value.respond_to? :[] and not value.respond_to? :upcase
        fail "You can pass only hash-like objects"
      end
    end
    
    def change_to_s(current, desire)
      changes = []
      if desire.respond_to? :[] and desire.respond_to? :keys
        keys = desire.keys.sort
        keys.each do |key|
          desired_value = desire[key]
          current_value = if current.respond_to? :[] then current[key] else nil end
          message = "option '#{key}' has changed from #{current_value.inspect} to #{desired_value.inspect}"
          changes << message unless current_value == desired_value   
        end
        changes.join ', '
      else
        "options has been set to #{desire.inspect}"
      end
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
      unless not value =~ /\s/ or value == ''
        raise ArgumentError, "Datasource host is invalid, given #{value.inspect}"
      end
    end
  end
  
  newproperty(:port) do
    desc "port to connect"
    isrequired
    validate do |value|
      unless value =~ /^\d+$/ or value == ''
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

  Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator.new(self).configure
  Puppet_X::Coi::Jboss::Type::RetryConfigurator.new(self).configure
end

