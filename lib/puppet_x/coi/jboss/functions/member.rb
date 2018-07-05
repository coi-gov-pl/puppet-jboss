# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. A member function from newer stdlib
    #
    # @see [puppetlabs/stdlib member function]
    #      (https://github.com/puppetlabs/puppetlabs-stdlib/blob/4.25.1/lib/puppet/parser/functions/member.rb)
    # @param arguments [Array] should be only two argument in array
    # @return [string] casted value to string
    def member(arguments)
      validate_method_parameters('jboss_member', arguments) do
        { :desc => '2', :condition => arguments.size != 2 }
      end
      item, array = unpack_arguments(arguments)
      ensure_not_empty(item)
      (item - array).empty?
    end

    private

    def unpack_arguments(arguments)
      array = arguments[0]
      unless array.is_a?(Array)
        raise(Puppet::ParseError, 'jboss_member(): Requires array to work with')
      end
      item = arguments[1]
      unless str_or_int?(item) || item.is_a?(Array)
        raise(Puppet::ParseError, 'jboss_member(): Item to search for must be a string, fixnum, or array')
      end
      item = str_or_int?(item) ? [item] : item
      [item, array]
    end

    def ensure_not_empty(value)
      msg = 'jboss_member(): You must provide item to search for within array given'
      raise(Puppet::ParseError, msg) if value.respond_to?(:'empty?') && value.empty?
    end

    def str_or_int?(value)
      value.is_a?(String) || value.is_a?(Integer)
    end
  end
end
