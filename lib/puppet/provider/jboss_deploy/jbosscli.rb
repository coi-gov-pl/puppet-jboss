require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_deploy).provide(:jbosscli,
  :parent => Puppet_X::Coi::Jboss::Provider::AbstractJbossCli) do

  desc 'JBoss CLI deploy provider'
  include Puppet_X::Coi::Jboss::Provider::Deploy
end
