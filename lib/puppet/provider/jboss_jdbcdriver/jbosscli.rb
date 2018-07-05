require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))

Puppet::Type.type(:jboss_jdbcdriver).provide(:jbosscli,
    :parent => PuppetX::Coi::Jboss::Provider::AbstractJbossCli) do

  desc 'JBoss CLI JDBC driver provider'

  @data = {}

  include PuppetX::Coi::Jboss::Provider::Jdbcdriver
end
