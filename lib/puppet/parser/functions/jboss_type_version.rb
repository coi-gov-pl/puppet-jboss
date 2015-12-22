require File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss/functions/jboss_type_version')

# Jboss AS private type version function
#
# jboss_type_version(string) : string
#
# Returns version type of JBoss version from full version string ex.: 'as-7.1.1.Final' -> 'as',
# 'eap-6.2.0.GA' -> 'eap'
module Puppet::Parser::Functions
  newfunction(:jboss_type_version, :type => :rvalue) do |args|
    Puppet_X::Coi::Jboss::Functions.jboss_type_version args
  end
end
