require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private to_s function
#
# jboss_to_s(object) : string
#
# Cast any object to string
module Puppet::Parser::Functions
  newfunction(:jboss_to_s, :type => :rvalue) do |args|
    PuppetX::Coi::Jboss::Functions.to_s(args)
  end
end
