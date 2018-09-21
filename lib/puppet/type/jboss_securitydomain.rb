require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet::Type.newtype(:jboss_securitydomain) do
  PuppetX::Coi::Jboss::Type::SecurityDomain.define(self)
end
