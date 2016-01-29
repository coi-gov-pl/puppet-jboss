# A module that holds JBoss datasource provider static metod
module Puppet_X::Coi::Jboss::Provider::Datasource::Static

  def instances
    runasdomain = self.config_runasdomain
    profile = self.config_profile
    controller = self.config_controller
    ctrlconfig = self.controllerConfig({ :controller  => controller })
    list = []
    cmd = self.compilecmd runasdomain, profile, "/subsystem=datasources:read-children-names(child-type=#{self.datasource_type true})"
    res = self.executeAndGet cmd, runasdomain, ctrlconfig, 0, 0
    if res[:result]
      res[:data].each do |name|
        inst = self.create_rubyobject name, true, runasdomain, profile, controller
        list.push inst
      end
    end
    cmd = self.compilecmd runasdomain, profile, "/subsystem=datasources:read-children-names(child-type=#{self.datasource_type false})"
    res = self.executeAndGet cmd, runasdomain, ctrlconfig, 0, 0
    if res[:result]
      res[:data].each do |name|
        inst = self.create_rubyobject name, false, runasdomain, profile, controller
        list.push inst
      end
    end
    return list
  end

  def create_rubyobject(name, xa, runasdomain, profile, controller)
    props = {
      :name        => name,
      :ensure      => :present,
      :provider    => :jbosscli,
      :xa          => xa,
      :runasdomain => runasdomain,
      :profile     => profile,
      :controller  => controller
    }
    obj = new(props)
    return obj
  end

  def datasource_type(xa)
    if xa
      "xa-data-source"
    else
      "data-source"
    end
  end
end
