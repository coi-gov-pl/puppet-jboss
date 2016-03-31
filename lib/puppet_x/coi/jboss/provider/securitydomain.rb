# A class for JBoss security domain provider
module Puppet_X::Coi::Jboss::Provider::SecurityDomain
  def create

    commands_template = create_parametrized_cmd
    commands = commands_template.join('/')

    cmd = compilecmd commands
    cmd2 = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)"

    cmd3 = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add()"

    bringUp('Security Domain Cache Type', cmd2)[:result]
    bringUp('SecurityDomain Authentication', cmd3)[:result]
    bringUp('Security Domain', cmd)[:result]
  end

  def destroy
    cmd = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:remove()"
    bringDown('Security Domain', cmd)[:result]
  end

  def exists?
    cmd = compilecmd "/subsystem=security:read-resource(recursive=true)"
    res = executeWithoutRetry cmd
    Puppet.debug("#{@resource[:name]}")
    if not res[:result]
      Puppet.debug "Security Domain does NOT exist"
      return false
    end
    undefined = nil
    lines = preparelines res[:lines]
    data = eval(lines)['result']
    name = @resource[:name]
    if data["security-domain"].key? @resource[:name]
      Puppet.debug('There is securitydomain with such name')
      if data['security-domain'][name]['authentication'].nil?
        Puppet.debug('Authentication does not exists')
        save_authentication false
      end
      return true
    else
      return false
    end
    Puppet.debug "Security Domain exists: #{data.inspect}"

    save_state(data)

    existinghash = Hash.new
    givenhash = Hash.new

    unless @resource[:moduleoptions].nil?
      @resource[:moduleoptions].each do |key, value|
        givenhash["#{key}"] = value.to_s.gsub(/\n/, ' ').strip
      end
    end

    data['login-modules'][0]['module-options'].each do |key, value|
      existinghash[key.to_s] = value.to_s.gsub(/\n/, ' ').strip
    end

    if !existinghash.nil? && !givenhash.nil? && existinghash != givenhash
      diff = givenhash.to_a - existinghash.to_a
      Puppet.notice "Security domain should be recreated. Diff: #{diff.inspect}"
      Puppet.debug "Security domain moduleoptions existing hash => #{existinghash.inspect}"
      Puppet.debug "Security domain moduleoptions given hash => #{givenhash.inspect}"
      destroy
      return false
    end
    return true
  end

  private

  def save_authentication data
    @auth = data if @auth.nil?
    @auth
  end

  def save_state data
    @state = data if @state.nil?
    @state
  end

  def state
    @state
  end

  # Method prepares lines outputed by JBoss CLI tool, changing output to be readable in Ruby
  #
  # @param {string[]} lines
  def preparelines lines
    lines.
      gsub(/\((\"[^\"]+\") => (\"[^\"]+\")\)/, '\1 => \2').
      gsub(/\[((?:[\n\s]*\"[^\"]+\" => \"[^\"]+\",?[\n\s]*)+)\]/m, '{\1}')
  end

  def create_parametrized_cmd
    provider_impl().make_command_templates()
  end

  def provider_impl
    require_relative 'securitydomain/pre_wildfly_provider'
    require_relative 'securitydomain/post_wildfly_provider'

    if @impl.nil?
      if Puppet_X::Coi::Jboss::Configuration::is_pre_wildfly?
        @impl = Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider.new(self)
      else
        @impl = Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider.new(self)
      end
    end
    @impl
  end
end
