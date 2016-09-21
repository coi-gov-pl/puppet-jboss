require_relative 'configuration'

# A class for JBoss facts
class Puppet_X::Coi::Jboss::Facts
  class << self
    # Add settings of jboss configuration file to facts
    def define_fullconfig_fact
      config = Puppet_X::Coi::Jboss::Configuration::read
      unless config.nil?
        config.each do |key, value|
          fact_symbol = "jboss_#{key}".to_sym
          add_fact fact_symbol, value
        end
        Facter.add(:jboss_fullconfig) do
          setcode do
            if Puppet_X::Coi::Jboss::Configuration.ruby_version < '1.9.0'
              class << config
                define_method(:to_s, proc { self.inspect })
              end
            end
            config
          end
        end
      end
    end

    # Check if is running inside Docker container
    # Implementation is taken from Facter 2.1.x
    # @deprecated TODO: remove after dropping support for Puppet 2.x
    # @return {boolean} true if running inside container
    def dockerized?
      path = Pathname.new('/proc/1/cgroup')
      return false unless path.readable?
      in_docker = path.readlines.any? {|l| l.split(":")[2].to_s.start_with? '/docker/' }
      return true if in_docker
      return false
    end

    # Add new fact with name and value taken from function parameters
    # @param {name} name of the fact to be added
    # @param {value} value of fact to be added
    def add_fact name, value
      Facter.add(name.to_sym) { setcode { value } }
    end
  end
end
