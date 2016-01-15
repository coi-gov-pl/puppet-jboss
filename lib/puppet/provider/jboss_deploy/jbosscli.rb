require File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'jbosscli.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss/provider/jboss_deploy.rb'))

Puppet::Type.type(:jboss_deploy).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  include Puppet_X::Coi::Jboss::Provider::JbossDeploy
end
