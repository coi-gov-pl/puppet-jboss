# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION.
    #
    # @param method_name [String] a method name
    # @param args [Array] an array of args
    # @param block [Block] a yeild block that should return description of args and condition
    def validate_method_parameters(method_name, args)
      info = yield
      raise_puppet_error(method_name, args.size, info[:desc]) if info[:condition]
    end

    private

    def raise_puppet_error(method_name, arg_size, arg_desc)
      raise(
        Puppet::ParseError,
        "#{method_name}(): Wrong number of arguments given (#{arg_size} for #{arg_desc})"
      )
    end
  end
end
