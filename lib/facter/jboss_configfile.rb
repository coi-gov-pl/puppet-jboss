require File.expand_path(File.join(File.dirname(__FILE__), '../puppet_x/coi/jboss'))

Facter.add(:jboss_configfile) do
  setcode { PuppetX::Coi::Jboss::Configuration.configfile }
end
