# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss
# A class for JBoss configuration
class Configuration
  class << self
  
    # Initialize configuration
    #
    # @return nil
    def initialize
      @config = nil
    end
  
    # Read the configuration with augeas
    #
    # @return [Hash] configuration in a hash object or nil if not avialable
    def read
      require 'augeas'
      
      map = nil
      configfile = Facter.value(:jboss_configfile)
      unless configfile.nil?
        aug = Augeas::open('/', nil, Augeas::NO_MODL_AUTOLOAD)
        aug.transform(:lens => 'Shellvars.lns', :incl => configfile, :name => 'jboss-as.conf')
        aug.load
        is_bool = lambda { |value| !/^(true|false)$/.match(value).nil? }
        to_bool = lambda { |value| if !/^true$/.match(value).nil? then true else false end }                                   
        map = {}
        aug.match("/files#{configfile}/*").each do |key|
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
  
  end
end

end
end
end