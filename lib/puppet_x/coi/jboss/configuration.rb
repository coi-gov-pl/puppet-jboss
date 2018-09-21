# A class for JBoss configuration
class PuppetX::Coi::Jboss::Configuration
  class << self
    @config = nil

    # Test method that return current version(for comatability with ruby 1.8)
    def ruby_version
      RUBY_VERSION
    end

    # Gets the main config file
    def configfile
      content = read_raw_profile_d.chomp
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
      map = nil
      cfgfile = configfile
      unless cfgfile.nil?
        is_bool = lambda { |value| !/^(true|false)$/.match(value).nil? }
        to_bool = lambda { |value| !/^true$/.match(value).nil? }
        map = {}
        aug = augeas_of(cfgfile)
        aug.match("/files#{cfgfile}/*").each do |key|
          m = key[/(JBOSS_.+)$/]
          next unless m
          v = aug.get(key)
          v = to_bool.call(v) if is_bool.call(v)
          map[m.downcase.sub('jboss_', '')] = v
        end
        aug.close
        map = unquote_hash_values(map)
      end
      map
    end

    # Checks is this execution is taking place on pre wildfly server
    #
    # @return [Boolean] true if execution is taking place on pre wildfly server
    def pre_wildfly?
      product = config_value(:product)
      version = config_value(:version)
      product == 'jboss-as' || (product == 'jboss-eap' && version < '6.3.0.GA')
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
      @config = read if @config.nil?
      ret = nil
      unless @config.nil?
        arr = @config.map { |k, v| [k.to_s.to_sym, v] }
        hash = Hash[arr]
        ret = hash[key.to_s.to_sym]
      end
      ret
    end

    # Method that reads file
    def read_raw_profile_d
      File.read('/etc/profile.d/jboss.sh')
    end

    private

    def augeas_of(file)
      require 'augeas'

      aug = Augeas.open('/', nil, Augeas::NO_MODL_AUTOLOAD)
      aug.transform(:lens => 'Shellvars.lns', :incl => file, :name => 'jboss-as.conf')
      aug.load
      aug
    end

    def unquote_hash_values(hash)
      Hash[*hash.map do |key, value|
        [key, value.respond_to?(:upcase) ? unquote(value) : value]
      end.flatten]
    end

    def unquote(string)
      result = string.dup

      case string[0, 1]
      when "'", '"', '`'
        result[0] = ''
      end

      case string[-1, 1]
      when "'", '"', '`'
        result[-1] = ''
      end

      result
    end
  end
end
