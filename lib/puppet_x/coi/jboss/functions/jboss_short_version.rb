# A custom class that holds custom functions
class Puppet_X::Coi::Jboss::Functions

  class << self
    # PRIVATE INTERNAL FUNCTION. Return the version of application server
    #
    # @param args [Array] should be only one argument in array
    # @return [string|string[]] the application server name(s)
    def jboss_short_version args
      raise(Puppet::ParseError, "jboss_short_version(): Wrong number of arguments given (#{args.size} for 1)") if args.size != 1

      version = args[0]
      re = /^(?:[a-z]+-)?(\d+\.\d+)\.\d+(?:\.[A-Za-z]+)?$/
      m = re.match(version)
      if m then m[1] else nil end
    end
  end
end
