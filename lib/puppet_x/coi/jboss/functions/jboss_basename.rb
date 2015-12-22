# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss
# A custom class that holds custom functions
class Functions

  class << self
    # PRIVATE INTERNAL FUNCTION. Returns the last component of the filename given in file_name
    #
    # @param args [Array] should be only one argument in array
    # @return [string|string[]] the file name(s)
    def jboss_basename args
      raise(Puppet::ParseError, "jboss_basename(): Wrong numbers of arguments given (#{args.size} for 1)") if args.size != 1
      input = args[0]
      if input.is_a?(Array)
        input.collect do |a| File.basename(a) end
      else
        File.basename(input)
      end
    end
  end
end
end
end
end
