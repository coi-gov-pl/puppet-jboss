Facter.add(:jboss_virtual) do
  setcode do
    if Puppet_X::Coi::Jboss::Facts.dockerized?
      'docker'
    else
      Facter.value(:virtual)
    end
  end
end
