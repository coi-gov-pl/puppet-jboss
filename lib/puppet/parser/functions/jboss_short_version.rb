require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss')

# Jboss AS private short version function
#
# jboss_short_version(string) : string
#
# Returns short version of JBoss version from full version string ex.: 'as-7.1.1.Final' -> '7.1',
# 'eap-6.2.0.GA' -> '6.2'
module Puppet::Parser::Functions
  newfunction(:jboss_short_version, :type => :rvalue) do |args|
    PuppetX::Coi::Jboss::Functions.short_version(args)
  end
end
