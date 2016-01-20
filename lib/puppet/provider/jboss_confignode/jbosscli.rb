require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_confignode).provide(:jbosscli,
    :parent => Puppet_X::Coi::Jboss::Provider::AbstractJbossCli) do

  desc 'JBoss CLI configuration node provider'

  @clean = false
  @data = nil

  include Puppet_X::Coi::Jboss::Provider::ConfigNode
end
