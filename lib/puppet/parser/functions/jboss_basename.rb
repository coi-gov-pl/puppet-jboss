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
    input = args[0]
    if input.is_a?(Array)
      input.collect do |a| File.basename(a) end
    else
      File.basename(input)
    end
  end
end
