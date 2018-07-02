require_relative 'configuration'

# A class for JBoss facts
class Puppet_X::Coi::Jboss::Facts
  class << self
    # Add settings of jboss configuration file to facts
    def define_fullconfig_fact
      config = Puppet_X::Coi::Jboss::Configuration.read
      define_facts_on_config(config) unless config.nil?
    end

    # Check if is running inside Docker container
    # Implementation is taken from Facter 2.1.x
    # @deprecated TODO: remove after dropping support for Puppet 2.x
    # @return {boolean} true if running inside container
    def dockerized?
      path = new_pathname '/proc/1/cgroup'
      return false unless path.readable?
      in_docker = path.readlines.any? { |l| l.split(':')[2].to_s.start_with? '/docker/' }
      return true if in_docker
      false
    end

    # Add new fact with name and value taken from function parameters
    # @param {name} name of the fact to be added
    # @param {value} value of fact to be added
    def add_fact(name, value)
      Facter.add(name.to_sym) { setcode { value } }
    end

    private

    def define_facts_on_config(config)
      define_jboss_facts_on_config(config)
      cfg = fixup_config(config)
      add_fact :jboss_fullconfig, cfg
    end

    def fixup_config(config)
      ret = config.dup
      if Puppet_X::Coi::Jboss::Configuration.ruby_version < '1.9.0'
        class << ret
          define_method(:to_s, proc { inspect })
        end
      end
      ret
    end

    def define_jboss_facts_on_config(config)
      config.each do |key, value|
        fact_symbol = "jboss_#{key}".to_sym
        add_fact fact_symbol, value
      end
    end

    def new_pathname(path)
      Pathname.new path
    end
  end
end
