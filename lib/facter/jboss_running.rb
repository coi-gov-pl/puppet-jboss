require File.expand_path(File.join(File.dirname(__FILE__), '../puppet_x/coi/jboss'))

PuppetX::Coi::Jboss::Facts.define_server_running_fact
