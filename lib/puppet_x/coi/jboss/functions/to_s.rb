# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Casts any value to string
    #
    # @param args [Array] should be only one argument in array
    # @return [string] casted value to string
    def to_s(args)
      validate_method_parameters('jboss_to_s', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      args[0].to_s
    end
  end
end
