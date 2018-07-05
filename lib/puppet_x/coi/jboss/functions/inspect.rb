# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Inspects any value to string
    #
    # @param args [Array] should be only one argument in array
    # @return [string] casted value to string
    def inspect(args)
      validate_method_parameters('jboss_inspect', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      inspect_value(args[0])
    end

    private

    def inspect_value(value)
      value.inspect
    end
  end
end
