require 'puppet/provider/jbosscli'

Puppet::Type.type(:securitydomain).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  def create
    runasdomain = @resource[:runasdomain]
    profile = @resource[:profile]
    cmd = "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add(login-modules=[{code=>\"#{@resource[:code]}\",flag=>\"#{@resource[:codeflag]}\",module-options=>["
    if runasdomain
      cmd = "/profile=#{profile}#{cmd}"
    end
    @resource[:moduleoptions].each_with_index do |(key, value), index|
      if not value.is_a? String
        value = value.to_s
      end
      value.gsub!(/\n/, ' ')
      cmd += "#{key}=>\"#{value}\""
      if index == @resource[:moduleoptions].length - 1
        break
      end
      cmd += ","
    end
    cmd += "]}])"
    cmd2 = "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)"
    if runasdomain
      cmd2 = "/profile=#{profile}#{cmd2}"
    end
    bringUp('Security Domain Cache Type', cmd2)[:result]
    bringUp('Security Domain', cmd)[:result]
  end

  def destroy
    runasdomain = @resource[:runasdomain]
    profile = @resource[:profile]
    cmd = "/subsystem=security/security-domain=#{@resource[:name]}:remove()"
    if runasdomain
      cmd = "/profile=#{profile}#{cmd}"
    end
    bringDown('Security Domain', cmd)[:result]
  end

  #
  def exists?
    runasdomain = @resource[:runasdomain]
    profile = @resource[:profile]
    cmd = "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:read-resource()"
    if runasdomain
      cmd = "/profile=#{profile}#{cmd}"
    end
    res = execute(cmd)
    if not res[:result]
      Puppet.debug("Security Domain does NOT exist")
      return false
    end
    Puppet.debug("Security Domain exists: #{res[:data].inspect}")

    lines = res[:lines]
    lines = lines.gsub( "(\"", "{\"" )
    lines = lines.gsub( "\")", "\"}" )
    lines = lines.gsub( "undefined", "nil" )
    b = eval(lines)
    existingmodulessize = b["result"]['login-modules'][0]['module-options'].size
    existingmoduleoptionshash = Hash.new
    givenmoduleoptionshash = Hash.new

    if !@resource[:moduleoptions].nil?
      givenmodulessize = @resource[:moduleoptions].size
      @resource[:moduleoptions].each_with_index do |(key, value), index|
        if not value.is_a? String
          value = value.to_s
        end
        value.gsub!(/\n/, ' ')
        givenmoduleoptionshash["#{key}"] = "#{value}"
      end
    end

    i = 0

    while i < existingmodulessize  do
      begin
        k = b["result"]['login-modules'][0]['module-options'][i].keys
        v = b["result"]['login-modules'][0]['module-options'][i].values
        existingmoduleoptionshash["#{k}"] = "#{v}"
      rescue
        Puppet.debug "Invalid: " + b["result"]['login-modules'].inspect
      end
      i += 1
    end

    if !existingmoduleoptionshash.nil? && !givenmoduleoptionshash.nil? && existingmoduleoptionshash != givenmoduleoptionshash
      Puppet.notice("Security domain should be recreated!")
      destroy
      return false
    end
    return true
  end
  
end
