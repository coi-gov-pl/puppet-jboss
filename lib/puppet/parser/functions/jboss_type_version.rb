# Jboss AS private type version function
#
# jboss_type_version(string) : string
#
# Returns version type of JBoss version from full version string ex.: 'as-7.1.1.Final' -> 'as',
# 'eap-6.2.0.GA' -> 'eap'
module Puppet::Parser::Functions
  newfunction(:jboss_type_version, :type => :rvalue) do |args|
    version = args[0]
    re = /^([a-z]+)-(?:\d+\.\d+)\.\d+(?:\.[A-Za-z]+)?$/
    m = re.match(version)
    if m then m[1] else nil end
  end
end