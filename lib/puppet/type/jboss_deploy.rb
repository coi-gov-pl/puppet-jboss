require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet::Type.newtype(:jboss_deploy) do
  PuppetX::Coi::Jboss::Type::Deploy.define(self)
end
