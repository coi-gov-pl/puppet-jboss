# A custom class that holds custom functions
class Puppet_X::Coi::Jboss::Functions

  class << self
    # PRIVATE INTERNAL FUNCTION. Casts any value to integer
    #
    # @param args [Array] should be only one argument in array
    # @return [int] casted value to integer of input value
    def jboss_to_i args
      if args.size != 1
        raise(Puppet::ParseError, "jboss_to_i(): Wrong number of arguments given (#{args.size} for 1)")
      end
      args[0].to_s.to_i
    end
  end
end
