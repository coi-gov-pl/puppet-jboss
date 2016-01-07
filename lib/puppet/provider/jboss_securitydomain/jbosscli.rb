require File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'jbosscli.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss/provider/securitydomain.rb'))

Puppet::Type.type(:jboss_securitydomain).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  include Puppet_X::Coi::Jboss::Provider::SecurityDomain
end
