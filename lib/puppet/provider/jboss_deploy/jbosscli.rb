require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_deploy).provide(:jbosscli,
  :parent => PuppetX::Coi::Jboss::Provider::AbstractJbossCli) do

  desc 'JBoss CLI deploy provider'
  include PuppetX::Coi::Jboss::Provider::Deploy
end
