require_relative 'configuration'

# A class for JBoss facts
class Puppet_X::Coi::Jboss::Facts
  class << self
    # Adds a Jboss running fact
    def define_jboss_running_fact
      Facter.add(:jboss_running) do
        setcode do
          Puppet_X::Coi::Jboss::Facts::search_process(
            /java.*-server.*(?:org\.jboss\.as|org\.wildfly)/
          ).nil?.equal? false
        end
      end
    end

    # Add settings of jboss configuration file to facts
    def define_fullconfig_fact
      Facter.add(:jboss_fullconfig) do
        setcode do
          config = Puppet_X::Coi::Jboss::Configuration::read
          unless config.nil?
            config.each do |key, value|
              fact_symbol = "jboss_#{key}".to_sym
              Puppet_X::Coi::Jboss::Facts::add_fact(fact_symbol, value)
            end
          end
          config
        end
      end
    end

    # Adds a configfile fact
    def define_configfile_fact
      Facter.add(:jboss_configfile) do
        setcode { Puppet_X::Coi::Jboss::Configuration::configfile }
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

    def search_process(pattern)
      glob = Puppet_X::Coi::Jboss::Configuration::system_processes_commandline
      result = Dir[glob].inject({}) do |h, file|
        (h[File.read(file).gsub(/\000/, ' ')] ||= []).push(file.match(/\d+/)[0].to_i)
        h
      end
      flat = result.map { |k, v| v if k.match(pattern) }.compact.flatten
      flat if flat.any?
    end

    # Add new fact with name and value taken from function parameters
    # @param {name} name of the fact to be added
    # @param {value} value of fact to be added
    def add_fact name, value
      fact_name = name.to_sym
      Facter.add(fact_name) { setcode { value } } if Facter.fact(fact_name).nil?
    end

    def system_processes_commandline
      '/proc/[0-9]*/cmdline'
    end
  end
end
