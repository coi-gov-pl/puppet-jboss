require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private to_bool function
#
# jboss_to_bool(object) : bool
#
# Cast any object to boolean
module Puppet::Parser::Functions
  newfunction(:jboss_to_bool, :type => :rvalue) do |args|
    PuppetX::Coi::Jboss::Functions.to_bool(args)
  end
end
