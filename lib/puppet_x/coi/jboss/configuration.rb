# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss
# A class for JBoss configuration
class Configuration
  class << self

    @config = nil


    # Add settings of jboss configuration file to facts
    def add_config_facts
      config = read
      unless config.nil?
        config.each do |key, value|
          fact_symbol = "jboss_#{key}".to_sym
          Facter.add(fact_symbol) do
            setcode { value }
          end
        end
        Facter.add(:jboss_fullconfig) do
          setcode do
            if RUBY_VERSION < '1.9.0'
              class << config
                define_method(:to_s, proc { self.inspect })
              end
            end
            config
          end
        end
      end
    end

    # refresh jboss configuration file facts
    def refresh_config_facts
      add_config_facts
    end

    # Gets the main config file
    def configfile
      content = self.read_raw_profile_d.chomp
      re = /export JBOSS_CONF=\'([^\']+)\'/
      m = re.match(content)
      m[1]
    rescue
      ENV['JBOSS_CONF']
    end

    # Read the configuration with augeas
    #
    # @return [Hash] configuration in a hash object or nil if not avialable
    def read
      require 'augeas'

      map = nil
      cfgfile = self.configfile
      unless cfgfile.nil?
        aug = Augeas::open('/', nil, Augeas::NO_MODL_AUTOLOAD)
        aug.transform(:lens => 'Shellvars.lns', :incl => cfgfile, :name => 'jboss-as.conf')
        aug.load
        is_bool = lambda { |value| !/^(true|false)$/.match(value).nil? }
        to_bool = lambda { |value| if !/^true$/.match(value).nil? then true else false end }
        map = {}
        aug.match("/files#{cfgfile}/*").each do |key|
            m = key[/(JBOSS_.+)$/]
            if m
                v = aug.get(key)
                v = to_bool.call(v) if is_bool.call(v)
                map[m.downcase.sub('jboss_', '')] = v
            end
        end
        aug.close
      end
      map
    end

    # Checks is this execution is taking place on pre wildfly server
    #
    # @return [Boolean] true if execution is taking place on pre wildfly server
    def is_pre_wildfly?
      product = self.config_value(:product)
      version = self.config_value(:version)
      product == 'jboss-as' or ( product == 'jboss-eap' and version < '6.3.0.GA' )
    end

    # Resets configuration
    #
    # @param value [Hash] optional value to reset to
    # @return nil
    def reset_config(value = nil)
      @config = value
      nil
    end

    # Gets configuration value by its symbol
    #
    # @param key [Symbol] a key in hash
    # @return [Object] configuration value
    def config_value(key)
      @config = self.read if @config.nil?
      ret = nil
      unless @config.nil?
        arr = @config.map { |k,v| [k.to_s.to_sym, v] }
        h = Hash[arr]
        ret = h[key]
      end
      ret
    end

    def read_raw_profile_d
      File.read('/etc/profile.d/jboss.sh')
    end

  end
end

end
end
end