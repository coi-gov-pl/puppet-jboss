# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # Will parse server version string
    # @param name [String] a name of the function
    # @param re [RegEx] regular expression
    # @param args [Array] should be only one argument in array
    # @return [string] the application server version string
    def version_parse(name, re, args)
      validate_method_parameters(name, args) do
        { :desc => '1', :condition => args.size != 1 }
      end
      version = args[0]
      match = re.match(version)
      match ? match[1] : nil
    end
  end
end
