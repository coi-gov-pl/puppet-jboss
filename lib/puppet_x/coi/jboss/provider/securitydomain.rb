# A class for JBoss security domain provider
module Puppet_X::Coi::Jboss::Provider::SecurityDomain

  # Method that creates security-domain in Jboss instance. When invoked it will execute 3 commands, add cache-type with value 'default', add authentication with value classic, add login-modules. Depends on the version of server it will use correct path to set security domain
  def create
    commands_template = create_parametrized_cmd
    commands = commands_template.join('/')

    cmd = compilecmd commands
    cmd2 = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)"

    bringUp('Security Domain Cache Type', cmd2)[:result]

    # TODO: Implement some nice way to decide if this method should be invoked, simple if is bleeeh.
    if not @auth
      cmd3 = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add()"
      bringUp('Security Domain Authentication', cmd3)[:result]
    end

    bringUp('Security Domain', cmd)[:result]
  end

  # Method to remove security-domain from Jboss instance
  def destroy
    cmd = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:remove()"
    bringDown('Security Domain', cmd)[:result]
  end

  # Method to check if there is security domain. Method calls recursive read-resource on security subsystem to validate if security domain is present. In the procces method also checks if authentication is set.
  def exists?
    cmd = compilecmd "/subsystem=security:read-resource(recursive=true)"
    res = executeWithoutRetry cmd

    if not res[:result]
      Puppet.debug "Security Domain does NOT exist"
      return false
    end

    undefined = nil
    lines = preparelines res[:lines]
    data = eval(lines)['result']
    name = @resource[:name]
    if data["security-domain"].key? @resource[:name]
      Puppet.debug "here is securitydomain with such name #{name}"
      if data['security-domain'][name]['authentication'].nil?
        Puppet.debug('Authentication does not exists')
        save_authentication false
      end
      save_authentication true
      return true
    else
      return false
    end
    Puppet.debug "Security Domain exists: #{data.inspect}"

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

  # Method that saves information abiut presence of authentication in Jboss instance
  # @param {boolean} boolean value that indicate if authentication is set
  # @return {boolean}
  def save_authentication data
    @auth = data if @auth.nil?
    @auth
  end

  # Method prepares lines outputed by JBoss CLI tool, changing output to be readable in Ruby
  # @param {string[]} lines
  def preparelines lines
    lines.
      gsub(/\((\"[^\"]+\") => (\"[^\"]+\")\)/, '\1 => \2').
      gsub(/\[((?:[\n\s]*\"[^\"]+\" => \"[^\"]+\",?[\n\s]*)+)\]/m, '{\1}')
  end

  # Method to create base for command to be executed when security domain is made
  # @return {[String]} list of command elements
  def create_parametrized_cmd
    provider_impl().make_command_templates()
  end

  # Method that provides information about which command template should be user_id
  # @return {Puppet_X::Coi::Jboss::Provider::SecurityDomain::PreWildFlyProvider|Puppet_X::Coi::Jboss::Provider::SecurityDomain::PostWildFlyProvider} provider with correct command template
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
