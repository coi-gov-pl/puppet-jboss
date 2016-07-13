# Class that holds information about current state of securitydomain
class Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState

  def initialize(is_cache_default = false, is_authentication = false, is_login_modules = false)
    @is_cache_default = is_cache_default
    @is_authentication = is_authentication
    @is_login_modules = is_login_modules
    @compilator = Puppet_X::Coi::Jboss::Internal::CommandCompilator.new
  end

  # Standard getter for cache_default
  # @return {Boolean} true if there is cache_default set
  def cache_default?
    @is_cache_default
  end

  # Standard setter fot cache_default
  # @param {Boolean} value
  def is_cache_default=(value)
    @is_cache_default = value
  end

  # Standard getter for authentication
  # @return {Boolean} true if there is authentication set
  def is_authentication
    @is_authentication
  end

  # Standard setter fot authentication
  # @param {Boolean} value
  def is_authentication=(value)
    @is_authentication = value
  end

  # Standard getter for login modules
  # @return {Boolean} true if there are login modules set
  def is_login_modules
    @is_login_modules
  end

  # Standard setter fot login modules
  # @param {Boolean} value
  def is_login_modules=(value)
    @is_login_modules = value
  end
end
