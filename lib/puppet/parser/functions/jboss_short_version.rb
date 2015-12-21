# Jboss AS private short version function
#
# jboss_short_version(string) : string
#
# Returns short version of JBoss version from full version string ex.: 'as-7.1.1.Final' -> '7.1',
# 'eap-6.2.0.GA' -> '6.2'
module Puppet::Parser::Functions
  newfunction(:jboss_short_version, :type => :rvalue) do |args|
    raise(Puppet::ParseError, "jboss_short_version(): Wrong number of arguments given (#{args.size} for 1)") if args.size != 1

    version = args[0]
    re = /^(?:[a-z]+-)?(\d+\.\d+)\.\d+(?:\.[A-Za-z]+)?$/
    m = re.match(version)
    if m then m[1] else nil end
  end
end
