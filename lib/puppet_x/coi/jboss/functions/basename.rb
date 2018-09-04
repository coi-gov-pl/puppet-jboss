# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Returns the base name of a file
    #
    # @param args [Array] should be only one argument in array
    # @return [string|string[]] the file name(s)
    def basename(args)
      validate_method_parameters('jboss_basename', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      input = args[0]
      if input.is_a?(Array)
        input.collect { |a| File.basename(a) }
      else
        File.basename(input)
      end
    end
  end
end
