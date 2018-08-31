require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_resourceadapter).provide(:jbosscli,
    :parent => PuppetX::Coi::Jboss::Provider::AbstractJbossCli) do

  desc 'JBoss CLI resource adapter provider'
  @data = nil

  include PuppetX::Coi::Jboss::Provider::ResourceAdapter
end
