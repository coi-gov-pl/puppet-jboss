Puppet::Type.newtype(:jmsqueue) do
  @doc = "jms for jboss-cli"
  ensurable

  newparam(:name) do
    desc ""
    isnamevar
  end

  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full"
  end

  newparam(:entries) do
    desc "entries separeted with comma"
  end

  newparam(:durable) do
    desc "durable true/false"
  end


end
