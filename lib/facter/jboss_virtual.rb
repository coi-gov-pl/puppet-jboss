require File.expand_path(File.join(File.dirname(__FILE__), '../puppet_x/coi/jboss'))

Facter.add(:jboss_virtual) do
  setcode do
    PuppetX::Coi::Jboss::Facts.virtual_fact_value
  end
end
