# A module for Type::Deploy
module PuppetX::Coi::Jboss::Type::Deploy
  def self.define(type)
    type.extend PuppetX::Coi::Jboss::Type::Deploy
    type.instance_eval do
      define_basics_type
      define_param_name
      define_param_source
      define_param_redeploy_on_refresh
      define_property_servergroups
      define_param_runtime_name

      # Native method that triggers when resource is changed
      def refresh
        provider.redeploy_on_refresh
      end
    end
    PuppetX::Coi::Jboss::Type::Meta.define(type)
  end

  private

  def define_basics_type
    @doc = 'Deploys and undeploys EAR/WAR artifacts on JBoss Application Server'
    ensurable
  end

  def define_param_name
    newparam(:name) do
      desc 'The JNDI resource name.'
      isnamevar
      isrequired
    end
  end

  def define_param_source
    newparam(:source) do
      desc 'Path to the EAR/WAR file.'
    end
  end

  def define_param_redeploy_on_refresh
    newparam(:redeploy_on_refresh, :boolean => true) do
      desc 'Force redeployment'
      defaultto true
    end
  end

  def define_property_servergroups
    newproperty(:servergroups, :array_matching => :all) do
      desc 'Array of server groups on which deployment should be done'
    end
  end

  def define_param_runtime_name
    newparam(:runtime_name) do
      desc 'Set the runtime-name'
      validate do |value|
        raise Puppet::Error, 'Invalid file extension, module only supports: .jar, .war, .ear, .rar' if (value =~ /.+(\.ear|\.zip|\.war|\.jar)$/).nil?
      end
    end
  end
end
