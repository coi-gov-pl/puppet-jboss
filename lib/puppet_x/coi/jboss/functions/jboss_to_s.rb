# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss
# A custom class that holds custom functions
class Functions

  class << self
    # PRIVATE INTERNAL FUNCTION. Casts any value to string
    #
    # @param args [Array] should be only one argument in array
    # @return [string] casted value to string
    def jboss_to_s args
      if args.size != 1
        raise(Puppet::ParseError, "jboss_to_s(): Wrong number of arguments given (#{args.size} for 1)")
      end
      args[0].to_s
    end
  end
end
end
end
end