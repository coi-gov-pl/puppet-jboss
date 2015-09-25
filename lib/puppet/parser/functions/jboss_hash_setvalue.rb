# Jboss AS private set value function
#
# jboss_hash_setvalue(Hash, string, Object) : void
#
# Sets value to Puppet hash
module Puppet::Parser::Functions
  newfunction(:jboss_hash_setvalue) do |args|
    hash, key, value = args
    hash[key] = value
  end
end