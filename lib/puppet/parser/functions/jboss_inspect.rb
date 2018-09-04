require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private inspect function
#
# jboss_inspect(object) : string
#
# Inspects any object to string using inspect
module Puppet::Parser::Functions
  newfunction(:jboss_inspect, :type => :rvalue) do |args|
    PuppetX::Coi::Jboss::Functions.inspect(args)
  end
end
