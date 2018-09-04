# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Sets a value in hash table by key
    #
    # @param args [Array] should be 3 elements in array: hash, key and value
    def hash_setvalue(args)
      validate_method_parameters('jboss_hash_setvalue', args) do
        { :desc => '3', :condition => args.size != 3 }
      end
      _, key, value = args
      hash = args[0]
      raise_first_arg_a_hashlike(hash) unless hash.respond_to?(:each_pair)
      hash[key] = value
      hash
    end

    private

    def raise_first_arg_a_hashlike(given)
      raise(
        Puppet::ParseError,
        "jboss_hash_setvalue(): First argument must be hashlike, given: #{given.inspect}"
      )
    end
  end
end
