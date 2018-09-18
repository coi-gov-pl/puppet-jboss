require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet::Type.newtype(:jboss_jdbcdriver) do
  PuppetX::Coi::Jboss::Type::JdbcDriver.define(self)
end
