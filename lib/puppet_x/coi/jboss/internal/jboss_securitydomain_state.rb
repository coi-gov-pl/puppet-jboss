class Puppet_X::Coi::Jboss::JbossSecurityDomainState

  def initialize(is_securitydomain = false, is_authentication = false, is_login_modules = false)
    @is_securitydomain = is_securitydomain
    @is_authentication = is_authentication
    @is_login_modules = is_login_modules
  end

end
