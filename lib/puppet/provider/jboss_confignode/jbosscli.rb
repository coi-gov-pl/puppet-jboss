require File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'jbosscli.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss/provider/confignode.rb'))

Puppet::Type.type(:jboss_confignode).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  @clean = false
  @data = nil
  include Puppet_X::Coi::Jboss::Provider::ConfigNode
end
