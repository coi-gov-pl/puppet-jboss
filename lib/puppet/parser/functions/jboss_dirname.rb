# Jboss AS private dirname function
#
# jboss_dirname(string) : string
# jboss_dirname(string[]) : string[]
#
# Returns all but the last component of the filename given as argument, which must be
# formed using forward slashes (``/..) regardless of the separator used on the
# local file system.
module Puppet::Parser::Functions
  newfunction(:jboss_dirname, :type => :rvalue) do |args|
    if args[0].is_a?(Array)
      args.collect do |a| File.dirname(a) end
    else
      File.dirname(args[0])
    end
  end
end