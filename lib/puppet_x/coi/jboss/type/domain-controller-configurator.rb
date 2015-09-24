require File.expand_path(File.join(File.dirname(__FILE__), '../../jboss'))

Puppet_X::Coi::Jboss.requirex 'type'

# A domain controller configurator for a Puppet type
class Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator

  # Constructor
  #
  # @param type [Puppet::Type] a child type
  # @return [Puppet::Type] a child type
  def initialize(type)
    @type = type
  end

  # Configures a type
  def configure
    configure_common_params
    configure_profile
  end

  def configure_without_profile
    configure_common_params
  end

  private

  def configure_common_params
    configure_controller
    configure_ctrluser
    configure_ctrlpasswd
    configure_runasdomain
  end

  # Configure a controller property
  def configure_controller
    @type.newparam(:controller) do
      desc "Domain controller host:port address"
      # Default is set to support listing of datasources without parameters (for easy use)
      defaultto "127.0.0.1:9990"
      validate do |value|
        if value == nil or value.to_s == 'undef'
          raise ArgumentError, "Domain controller must be provided"
        end
      end
    end
  end

  # Configure a ctrluser property
  def configure_ctrluser
    @type.newparam :ctrluser do
      desc 'A user name to connect to controller'
    end
  end

  # Configure a ctrlpasswd property
  def configure_ctrlpasswd
    @type.newparam :ctrlpasswd do
      desc 'A password to be used to connect to controller'
    end
  end

  # Configure a profile property
  def configure_profile
    @type.newparam(:profile) do
      desc "The JBoss profile name"
      defaultto "full"
    end
  end

  # Configure a runasdomain property
  def configure_runasdomain
    @type.newparam(:runasdomain, :boolean => true) do
      desc "Indicate that server is in domain mode"
      defaultto true
    end
  end

end