Puppet::Type.newtype(:datasource) do
  @doc = "Data source for JBoss domains"
  ensurable

  newparam(:name) do
    desc ""
    isnamevar
  end

  newparam(:profile) do
    desc "The JBoss datasource profile name"
    defaultto "default"
  end

  newparam(:jndiname) do
    desc "jndi-name"
  end

  newparam(:drivername) do
    desc "driver-name"
  end

  newparam(:minpoolsize) do
    desc "min-pool-size"
  end

  newparam(:maxpoolsize) do
    desc "max-pool-size"
  end

  newparam(:username) do
    desc "user-name"
  end

  newparam(:password) do
    desc "The internal JBoss user asadmin uses. Default: admin"
  end

  newparam(:validateonmatch) do
    desc "validate-on-match"
  end

  newparam(:backgroundvalidation) do
    desc "background-validation"
  end

  newparam(:sharepreparestatements) do
    desc "share-prepare-statements"
  end

  newparam(:xadatasourceproperties) do
    desc "xa-datasource-properties list, separated by comma"
  end

end
