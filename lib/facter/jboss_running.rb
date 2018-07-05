require File.expand_path(File.join(File.dirname(__FILE__), '../puppet_x/coi/jboss'))

Facter.add(:jboss_running) do
  setcode do
    status = PuppetX::Coi::Jboss::Facts.server_running?
    status.inspect
  end
end
