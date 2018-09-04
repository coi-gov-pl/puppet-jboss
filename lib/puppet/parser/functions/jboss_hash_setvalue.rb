require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private set value function
#
# jboss_hash_setvalue(Hash, string, Object) : void
#
# Sets value to Puppet hash
module Puppet::Parser::Functions
  newfunction(:jboss_hash_setvalue) do |args|
    PuppetX::Coi::Jboss::Functions.hash_setvalue(args)
  end
end
