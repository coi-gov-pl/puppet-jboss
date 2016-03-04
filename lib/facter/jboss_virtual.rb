Facter.add(:jboss_virtual) do
  setcode do
    virtual = Facter.value(:virtual)
    ret = virtual
    ret = 'docker' if virtual == 'physical' and Puppet_X::Coi::Jboss::Facts.dockerized?
    ret
  end
end
