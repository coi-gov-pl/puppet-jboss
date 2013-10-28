Puppet::Type.newtype(:securitydomain) do
  @doc = "Security-domain configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc ""
    isnamevar
  end

  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full"
  end

  newparam(:moduleoptions) do
    desc "module-options given as a table"
  end

  newparam(:code) do
    desc "code for JBOSS security-domain"
  end

  newparam(:codeflag) do
    desc "codeflag for JBOSS security-domain"
  end
  
  newparam(:runasdomain) do
    desc "Run server in domain mode"
    defaultto true
  end
  
  newparam(:controller) do
    desc "Domain controller host:port address"
    defaultto "localhost:9999"
    validate do |value|
      if value == nil and @resource[:runasdomain]
        raise ArgumentError, "Domain controller must be provided"
      else
        super
      end
    end
  end

end
