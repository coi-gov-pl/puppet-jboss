require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet::Type.newtype(:jboss_jmsqueue) do
  PuppetX::Coi::Jboss::Type::JmsQueue.define(self)
end
