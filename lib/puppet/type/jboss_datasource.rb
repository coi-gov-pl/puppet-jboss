require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet::Type.newtype(:jboss_datasource) do
  PuppetX::Coi::Jboss::Type::DataSource.define(self)
end
