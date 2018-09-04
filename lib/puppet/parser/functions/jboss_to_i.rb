require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private to_i function
#
# jboss_to_i(string) : int
#
# Cast string to integer
module Puppet::Parser::Functions
  newfunction(:jboss_to_i, :type => :rvalue) do |args|
    PuppetX::Coi::Jboss::Functions.to_i(args)
  end
end
