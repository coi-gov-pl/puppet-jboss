Puppet::Type.newtype(:deploy) do
  @doc = "Deploys and undeploys EAR/WAR artifacts on JBoss Application Server"
  ensurable

  newparam(:name) do
    desc "The JDBC resource name."
    isnamevar
  end

  newparam(:source) do
    desc "Path to the EAR/WAR file."
  end

  newparam(:runasdomain) do
    desc "Run server in domain mode"
    defaultto true
  end

end
