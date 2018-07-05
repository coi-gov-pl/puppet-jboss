require_relative 'configuration'

# A class for JBoss facts
class PuppetX::Coi::Jboss::Facts
  class << self
    # Add settings of jboss configuration file to facts
    def define_fullconfig_fact
      config = PuppetX::Coi::Jboss::Configuration.read
      define_facts_on_config(config) unless config.nil?
    end

    # Checks if server is actualy running as the moment of resolving the fact
    # It's checked by scanning running processes on machine
    # @return {boolean} true, if server is running
    def server_running?
      re = /java .* -server .* org\.jboss\.as/
      search_process_by_pattern(re).nil?.equal? false
    end

    # Gets the value of a patched virtual fact.
    # @deprecated TODO: remove after dropping support for Puppet 2.x
    # @return {string} a type of virtual like: docker, physical, vmware etc.
    def virtual_fact_value
      if dockerized?
        'docker'
      else
        Facter.value(:virtual)
      end
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

    def search_process_by_pattern(pattern)
      result = Dir['/proc/[0-9]*/cmdline'].each_with_object({}) do |file, h|
        (h[File.read(file).gsub(/\000/, ' ')] ||= []).push(file.match(/\d+/)[0].to_i)
      end
      result = result.map { |k, v| v if k.match(pattern) }.compact.flatten
      result if result.any?
    end

    def define_facts_on_config(config)
      define_jboss_facts_on_config(config)
      cfg = fixup_config(config)
      add_fact :jboss_fullconfig, cfg
    end

    def fixup_config(config)
      ret = config.dup
      if PuppetX::Coi::Jboss::Configuration.ruby_version < '1.9.0'
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
