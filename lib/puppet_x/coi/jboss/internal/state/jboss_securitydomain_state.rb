# Class that holds information about current state of securitydomain
class Puppet_X::Coi::Jboss::Internal::State::JbossSecurityDomainState

  def initialize(is_cache_default = false, is_authentication = false, is_login_modules = false)
    @is_cache_default = is_cache_default
    @is_authentication = is_authentication
    @is_login_modules = is_login_modules
    @compilator = Puppet_X::Coi::Jboss::Internal::JbossCompilator.new
  end

  def cache_default?
    @is_cache_default
  end

  def is_authentication
    @is_authentication
  end

  def is_login_modules
    @is_login_modules
  end
end
