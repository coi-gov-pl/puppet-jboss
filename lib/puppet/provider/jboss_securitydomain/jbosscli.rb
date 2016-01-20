require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_securitydomain).provide(:jbosscli,
    :parent => Puppet_X::Coi::Jboss::Provider::AbstractJbossCli) do
  include Puppet_X::Coi::Jboss::Provider::SecurityDomain
end
