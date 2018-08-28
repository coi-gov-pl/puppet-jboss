require_relative 'configuration'

# A class for JBoss facts
class PuppetX::Coi::Jboss::Facts
  class << self
    # Add settings of jboss configuration file to facts
    def define_fullconfig_fact
      config = PuppetX::Coi::Jboss::Configuration.read
      define_facts_on_config(config) unless config.nil?
    end

    # Defines a initsystem fact to be used by internal mechanisms
    def define_initsystem_fact
      initsystem = calculate_initsystem(
        Facter.value(:osfamily),
        Facter.value(:operatingsystem),
        Facter.value(:operatingsystemrelease)
      )
      add_fact('jboss_initsystem', initsystem.to_s) unless initsystem == :unsupported
    end

    # Defines a patched virtual fact to be used by internal mechanisms.
    #
    # @deprecated TODO: remove after dropping support for Puppet 2.x
    # @return {string} a type of virtual like: docker, physical, vmware etc.
    def define_virtual_fact
      add_fact('jboss_virtual', virtual_fact_value)
    end

    # Checks if server is actualy running as the moment of resolving the fact
    # It's checked by scanning running processes on machine
    # @return {boolean} true, if server is running
    def server_running?
      re = /java .* -server .* org\.jboss\.as/
      search_process_by_pattern(re).nil?.equal? false
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

    # Calculates an initsystem based on OS facts
    # @param {string} osfamily - an os family fact value
    # @param {string} os       - an operatingsystem fact value
    # @param {string} release  - an operatingsystemrelease family fact value
    # @return {symbol} an initsysem fact value, or :unsupported if so
    def calculate_initsystem(osfamily, os, release)
      case osfamily
      when 'RedHat'
        calculate_redhat_initsystem(os, release)
      when 'Debian'
        calculate_debian_initsystem(os, release)
      else
        :unsupported
      end
    end

    # Add new fact with name and value taken from function parameters
    # @param {string} name of the fact to be added
    # @param {string} value of fact to be added
    def add_fact(name, value)
      Facter.add(name.to_sym) { setcode { value } }
    end

    private

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

    def calculate_redhat_initsystem(os, release)
      case os
      when 'RedHat', 'CentOS', 'OracleLinux', 'Scientific', 'OEL'
        release >= '7.0' ? :SystemD : :SystemV
      when 'Fedora'
        release >= '21' ? :SystemD : :SystemV
      else
        :unsupported
      end
    end

    def calculate_debian_initsystem(os, release)
      case os
      when 'Ubuntu'
        release >= '15.04' ? :SystemD : :SystemV
      when 'Debian'
        release >= '8' ? :SystemD : :SystemV
      else
        :unsupported
      end
    end

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
