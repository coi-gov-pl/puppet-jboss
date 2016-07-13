# Internal class to audits what is the state of securitydomain in Jboss instance
# Do not use outside of securitydomain provider
class Puppet_X::Coi::Jboss::Internal::SecurityDomainAuditor
  # Standard constructor
  # @param {Hash} resource standard puppet resource object
  # @param {Puppet_X::Coi::Jboss::Internal::CliExecutor} cli_executor that will handle execution of command
  # @param {Puppet_X::Coi::Jboss::Internal::CommandCompilator} compilator object that handles
  # compilaton of command to be executed
  # @param {Puppet_X::Coi::Jboss::Internal::SecurityDomainDestroyer} destroyer object that handles removing of
  # securitydomain
  def initialize(resource, cli_executor, compilator, destroyer)
    @resource = resource
    @cli_executor = cli_executor
    @compilator = compilator
    @destroyer = destroyer
  end

  attr_reader :state

  # Method that checks if securitydomain exists
  # @return {Boolean} returns true if security-domain exists in any state
  def exists?
    raw_result = read_resource_recursive

    unless raw_result[:result]
      Puppet.debug 'Security Domain does NOT exist'
      return false
    end
    Puppet.debug("Raw result: #{raw_result.inspect}")
    result = resolve_state(raw_result[:data], @resource)
    result
  end

  # Internal mathod that saves current state of every subpath of securitydomain
  def fetch_securtydomain_state
    data = state
    if data['security-domain'][(@resource[:name]).to_s]
      fetched_state = Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState.new
      if data['security-domain'][(@resource[:name]).to_s]['cache-type'].nil?
        Puppet.debug('cache-type is nil')
        fetched_state.is_cache_default = false
      else
        fetched_state.is_cache_default = true
      end
      auth = data['security-domain'][(@resource[:name]).to_s]['authentication']
      if auth.nil?
        Puppet.debug('Authentication is nil')
        fetched_state.is_authentication = false
      else
        fetched_state.is_authentication = true
      end
      if !auth.nil? && (data['security-domain'][(@resource[:name]).to_s]['authentication']['classic']['login-modules'].nil? || data['security-domain'][(@resource[:name]).to_s]['authentication']['classic']['login-modules'][0]['module-options'].nil?)
        Puppet.debug('Login modules are nil')
        fetched_state.is_login_modules = false
      end
    else
      fetched_state = Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState.new
    end

    fetched_state
  end

  private

  # Method prepares lines outputed by JBoss CLI tool, changing output to be readable in Ruby
  # @param {string[]} lines
  def preparelines(lines)
    lines
      .gsub(/\((\"[^\"]+\") => (\"[^\"]+\")\)/, '\1 => \2')
      .gsub(/\[((?:[\n\s]*\"[^\"]+\" => \"[^\"]+\",?[\n\s]*)+)\]/m, '{\1}')
  end

  # Method that handles execution of command
  def read_resource_recursive
    cmd = @compilator.compile(@resource[:runasdomain],
                              @resource[:profile],
                              '/subsystem=security:read-resource(recursive=true)')
    conf = {
      controller: @resource[:controller],
      ctrluser: @resource[:ctrluser],
      ctrlpasswd: @resource[:ctrlpasswd]
    }
    @cli_executor.executeAndGet(cmd, @resource[:runasdomain], conf, 0, 0)
  end

  # Method that checks current situation of security-domain in Jboss instance
  # @param {Hash} actual_data output of recursive read of security-domain resource
  # @param {Hash} resource reference to standard puppet resource object
  # @return {Boolean} return true if security-domain with given name exists in any state
  def resolve_state(actual_data, resource)
    @state = actual_data
    unless actual_data.key? 'security-domain'
      Puppet.debug('There is no securitydomain at all')
      return false
    end

    Puppet.debug "Security Domain exists: #{actual_data.inspect}"

    givenhash = build_givenhash(resource)

    path_in_state = ['security-domain',
                     resource[:name].to_s,
                     'authentication',
                     'classic',
                     'login-modules',
                     0,
                     'module-options']

    nil_checker = get_nillable_from_hash_iterative(actual_data, path_in_state)

    Puppet.debug("Value of nil checker: #{nil_checker}")
    return false if nil_checker.nil?

    state_login_modules = array_keys_to_hash_value(actual_data, path_in_state)
    existinghash = build_existinghash(state_login_modules)

    if !existinghash.nil? && !givenhash.nil? && existinghash != givenhash
      diff = givenhash.to_a - existinghash.to_a
      Puppet.notice("Security domain should be recreated. Diff: #{diff.inspect}")
      Puppet.debug("Security domain moduleoptions existing hash => #{existinghash.inspect}")
      Puppet.debug("Security domain moduleoptions given hash => #{givenhash.inspect}")
      @destroyer.destroy(resource)
      return false
    end
    true
  end

  # Method that will build hash that holds informations about state that is desired
  # @param {Hash} data
  # @return {Hash} givenhash with informations about setting of security-domain
  def build_givenhash(data)
    givenhash = {}
    unless data[:moduleoptions].nil?
      data[:moduleoptions].each do |key, value|
        givenhash[key.to_s] = value.to_s.tr("\n", ' ').strip
      end
    end
    givenhash
  end

  # Method that will build hash that holds informations about actual settings of security-domain
  # @param {Hash} data
  # @return {Hash} existinghash with informations about desired setting of security-domain
  def build_existinghash(data)
    existinghash = {}
    data.each do |key, value|
      existinghash[key.to_s] = value.to_s.tr("\n", ' ').strip
    end
    existinghash
  end

  # Method that return value of last given in param
  # @param {Hash} data hash that holds desired information
  # @param {Array} keys array of keys in correct order that will be used to exctract value
  # @return {Object} tmp_data value of last key in keys parameter
  def array_keys_to_hash_value(data, keys)
    tmp_data = data
    keys.each do |key|
      tmp_data = tmp_data[key]
    end
    tmp_data
  end

  # Iterative method that check if there is nil value in given hash under keys that are given
  # as parameters
  # @param {Hash} hash hash that will be checked
  # @param {Array} keys keys that will be used to check if their value is null
  # @return {nil|String} result will be nil if there is nill value under key in given hash
  # or true if there is no nill value
  def get_nillable_from_hash_iterative(hash, keys)
    data = hash
    keys.each do |key|
      return nil if data[key].nil?
      data = data[key]
    end
  end
end
