# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # Return type of application server from given input string for ex.:
    # 'eap' for 'eap-6.2.0.GA'
    #
    # @param args [Array] application server description in array
    # @return [string] the application server type
    def type_version(args)
      re = /^([a-z]+)-(?:\d+\.\d+)\.\d+(?:\.[A-Za-z]+)?$/
      version_parse('jboss_type_version', re, args)
    end
  end
end
