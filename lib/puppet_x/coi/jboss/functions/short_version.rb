# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Return the version of application server
    #
    # @param args [Array] should be only one argument in array
    # @return [string|string[]] the application server name(s)
    def short_version(args)
      validate_method_parameters('jboss_short_version', args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      version = args[0]
      re = /^(?:[a-z]+-)?(\d+\.\d+)\.\d+(?:\.[A-Za-z]+)?$/
      m = re.match(version)
      m ? m[1] : nil
    end
  end
end
