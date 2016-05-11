# Class that holds information about current state of securitydomain
class Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState

  def initialize(is_cache_default = false, is_authentication = false, is_login_modules = false)
    @is_cache_default = is_cache_default
    @is_authentication = is_authentication
    @is_login_modules = is_login_modules
    @compilator = Puppet_X::Coi::Jboss::Internal::CommandCompilator.new
  end

  def cache_default?
    @is_cache_default
  end

  def is_cache_default=(value)
    @is_cache_default = value
  end

  def is_authentication
    @is_authentication
  end

  def is_authentication=(value)
    @is_authentication = value
  end

  def is_login_modules
    @is_login_modules
  end

  def is_login_modules=(value)
    @is_login_modules = value
  end
end
