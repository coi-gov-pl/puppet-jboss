# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # Return the version of application server as short number string
    # for ex.: '7.1' for ''.
    #
    # @param args [Array] application server description in array
    # @return [string] the short version string
    def short_version(args)
      re = /^(?:[a-z]+-)?(\d+\.\d+)\.\d+(?:\.[A-Za-z]+)?$/
      version_parse('jboss_short_version', re, args)
    end
  end
end
