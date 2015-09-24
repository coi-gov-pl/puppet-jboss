require File.expand_path(File.join(File.dirname(__FILE__), '../../puppet_x/coi/jboss'))

Puppet_X::Coi::Jboss.requirex 'type/domain-controller-configurator'
Puppet_X::Coi::Jboss.requirex 'type/retry-configurator'

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
  
  newparam(:code) do
    desc "code for JBOSS security-domain"
  end

  newparam(:codeflag) do
    desc "codeflag for JBOSS security-domain"
  end

  Puppet_X::Coi::Jboss::Type::DomainControllerConfigurator.new(self).configure
  Puppet_X::Coi::Jboss::Type::RetryConfigurator.new(self).configure

end
