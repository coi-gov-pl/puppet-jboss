require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private basename function
#
# jboss_basename(string) : string
# jboss_basename(string[]) : string[]
#
# Returns the last component of the filename given as argument, which must be
# formed using forward slashes (``/..) regardless of the separator used on the
# local file system.
module Puppet::Parser::Functions
  newfunction(:jboss_basename, :type => :rvalue) do |args|
    Puppet_X::Coi::Jboss::Functions.jboss_basename args
  end
end
