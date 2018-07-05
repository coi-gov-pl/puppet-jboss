require File.expand_path(File.join(File.dirname(__FILE__), '../../../puppet_x/coi/jboss'))
require 'uri'

Puppet::Type.type(:jboss_datasource).provide(:jbosscli,
    :parent => PuppetX::Coi::Jboss::Provider::AbstractJbossCli) do

  desc 'JBoss CLI datasource provider'

  @data   = nil
  @readed = false
  @impl   = nil

  include PuppetX::Coi::Jboss::Provider::Datasource

  class << self
    include PuppetX::Coi::Jboss::Provider::Datasource::Static
  end

end
