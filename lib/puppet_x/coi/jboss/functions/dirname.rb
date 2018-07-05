# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Returns the dirname of a file
    #
    # @param args [Array] should be only one argument in array
    # @return [string|string[]] the file path(s)
    def dirname(args)
      validate_method_parameters('jboss_dirname', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      if args[0].is_a?(Array)
        args[0].collect { |a| File.dirname(a) }
      else
        File.dirname(args[0])
      end
    end
  end
end
