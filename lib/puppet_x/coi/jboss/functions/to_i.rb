# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Casts any value to integer
    #
    # @param args [Array] should be only one argument in array
    # @return [int] casted value to integer of input value
    def to_i(args)
      validate_method_parameters('jboss_to_i', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      args[0].to_s.to_i
    end
  end
end
