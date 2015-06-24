Puppet::Type.newtype(:jboss_securitydomain) do
  @doc = "Security-domain configuration for JBoss Application Sever"
  ensurable

  newparam(:name) do
    desc ""
    isnamevar
  end

  newparam(:moduleoptions) do
    desc "module-options given as a table"
  end

  newparam(:profile) do
    desc "The JBoss profile name"
    defaultto "full"
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
      end
    end
  end
  
  newparam :ctrluser do
    desc 'A user name to connect to controller'
  end

  newparam :ctrlpasswd do
    desc 'A password to be used to connect to controller'
  end

  newparam :retry do
    desc "Number of retries."
    defaultto 3
  end

  newparam :retry_timeout do
    desc "Retry timeout in seconds"
    defaultto 1
  end
  
  newparam(:code) do
    desc "code for JBOSS security-domain"
  end

  newparam(:codeflag) do
    desc "codeflag for JBOSS security-domain"
  end

end
