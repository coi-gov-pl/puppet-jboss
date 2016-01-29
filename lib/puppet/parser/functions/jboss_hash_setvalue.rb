# Jboss AS private set value function
#
# jboss_hash_setvalue(Hash, string, Object) : void
#
# Sets value to Puppet hash
module Puppet::Parser::Functions
  newfunction(:jboss_hash_setvalue) do |args|
    raise(Puppet::ParseError, "jboss_hash_setvalue(): wrong lenght of input given (#{args.size} for 3)") if args.size != 3
    hash, key, value = args
    hash[key] = value
  end
end
