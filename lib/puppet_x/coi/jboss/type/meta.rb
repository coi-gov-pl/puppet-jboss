# A module for Type::Meta
module PuppetX::Coi::Jboss::Type::Meta
  def self.define(type, profile = true)
    type.instance_eval do
      if profile
        newparam(:profile) do
          desc 'The JBoss profile name'
          defaultto 'full'
        end
      end

      newparam(:runasdomain) do
        desc 'Run server in domain mode'
        defaultto true
      end

      newparam(:controller) do
        desc 'Domain controller host:port address'
        defaultto '127.0.0.1:9990'
        validate do |value|
          if value.nil? || value.to_s == 'undef'
            raise Puppet::Error, 'Domain controller must be provided'
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
        desc 'Number of retries.'
        defaultto 3
      end

      newparam :retry_timeout do
        desc 'Retry timeout in seconds'
        defaultto 1
      end
    end
  end
end
