# Class that holds information about current state of securitydomain
class PuppetX::Coi::Jboss::Internal::State::SecurityDomainState

  # Standard constructor
  # @param {Boolean} is_cache_default true if there is cache default in system
  # @param {Boolean} is_authentication true if there is authentication in system
  # @param {Boolean} is_login_modules true if there are login modules in system
  def initialize(is_cache_default = false, is_authentication = false, is_login_modules = false)
    @is_cache_default = is_cache_default
    @is_authentication = is_authentication
    @is_login_modules = is_login_modules
    @compilator = PuppetX::Coi::Jboss::Internal::CommandCompilator.new
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

  # Standard setter fot authenticationg
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
