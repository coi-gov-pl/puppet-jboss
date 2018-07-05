require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_securitydomain).provide(:jbosscli,
    :parent => PuppetX::Coi::Jboss::Provider::AbstractJbossCli) do
  include PuppetX::Coi::Jboss::Provider::SecurityDomain
end
