require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private to_s function
#
# jboss_to_s(object) : string
#
# Cast any object to string
module Puppet::Parser::Functions
  newfunction(:jboss_to_s, :type => :rvalue) do |args|
    Puppet_X::Coi::Jboss::Functions.jboss_to_s args
  end
end
