# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Return type of application server given as input
    #
    # @param args [Array] should be only one argument in array
    # @return [string|string[]] the application server name
    def type_version(args)
      validate_method_parameters('jboss_type_version', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      version = args[0]
      re = /^([a-z]+)-(?:\d+\.\d+)\.\d+(?:\.[A-Za-z]+)?$/
      match = re.match(version)
      match ? match[1] : nil
    end
  end
end
