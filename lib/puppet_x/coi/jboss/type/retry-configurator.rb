require File.expand_path(File.join(File.dirname(__FILE__), '../../jboss'))

Puppet_X::Coi::Jboss.requirex 'type'

# A retry configurator for a Puppet type
class Puppet_X::Coi::Jboss::Type::RetryConfigurator

  # Constructor
  #
  # @param type [Puppet::Type] a child type
  # @return [Puppet::Type] a child type
  def initialize(type)
    @type = type
  end

  # Configures a type
  def configure
    configure_retry
    configure_retry_timeout
  end

  def configure_retry
    @type.newparam :retry do
      desc "Number of retries."
      defaultto 3
    end
  end

  def configure_retry_timeout
    @type.newparam :retry_timeout do
      desc "Retry timeout in seconds"
      defaultto 1
    end
  end

end