Puppet::Type.newtype(:deploy) do
  @doc = "Deploys EAR/WAR file on JBOSS"
  ensurable

  newparam(:name) do
    desc "The JDBC resource name."
    isnamevar
  end

  newparam(:source) do
    desc "Path to the EAR/WAR file."
  end

  # newparam(:portbase) do
    # desc "The Glassfish domain port base. Default: 4800"
    # defaultto "4800"
  # end

end
