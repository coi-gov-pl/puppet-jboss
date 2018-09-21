# A module for Type::Deploy
module PuppetX::Coi::Jboss::Type::Deploy
  def self.define(type)
    type.instance_eval do
      @doc = 'Deploys and undeploys EAR/WAR artifacts on JBoss Application Server'
      ensurable

      newparam(:name) do
        desc 'The JNDI resource name.'
        isnamevar
        isrequired
      end

      newparam(:source) do
        desc 'Path to the EAR/WAR file.'
      end

      newparam(:redeploy_on_refresh, :boolean => true) do
        desc 'Force redeployment'
        defaultto true
      end

      newproperty(:servergroups, :array_matching => :all) do
        desc 'Array of server groups on which deployment should be done'
      end

      newparam(:runtime_name) do
        desc 'Set the runtime-name'
        validate do |value|
          raise Puppet::Error, 'Invalid file extension, module only supports: .jar, .war, .ear, .rar' if (value =~ /.+(\.ear|\.zip|\.war|\.jar)$/).nil?
        end
      end

      # Native method that triggers when resource is changed
      def refresh
        provider.redeploy_on_refresh
      end
    end
    PuppetX::Coi::Jboss::Type::Meta.define(type)
  end
end
