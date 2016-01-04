# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss
# A custom class that holds custom functions
class Functions

  class << self
    # PRIVATE INTERNAL FUNCTION. Returns the forst component of the filename given in file_name
    #
    # @param args [Array] should be only one argument in array
    # @return [string|string[]] the file path(s)
    def jboss_dirname args
      raise(Puppet::ParseError, "jboss_dirname(): Wrong numbers of arguments given (#{args.size} for 1)") if args.size != 1
      if args[0].is_a?(Array)
        args[0].collect do |a| File.dirname(a) end
      else
        File.dirname(args[0])
      end
    end
  end
end
end
end
end
