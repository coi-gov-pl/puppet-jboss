# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Casts any value to boolean
    #
    # @param args [Array] should be only one argument in array
    # @return [string] casted value to boolean
    def to_bool(args)
      validate_method_parameters('jboss_to_bool', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      string = args[0]
      # If string is already Boolean, return it
      return string if !(!string) == string
      string = string.to_s if string.is_a?(Symbol)
      string = string.inspect unless string.is_a?(String)

      # We consider all the yes, no, y, n and so on too ...
      to_bool_cases(string)
    end

    private

    def to_bool_cases(string)
      case string
      # This is how undef looks like in Puppet ...
      # We yield false in this case.
      when /^$/, '' then false # Empty string will be false ...
      when /^(1|t|y|true|yes)$/  then true
      when /^(0|f|n|false|no)$/  then false
      when /^(undef|undefined)$/ then false # This is not likely to happen ...
      else false
      end
    end
  end
end
