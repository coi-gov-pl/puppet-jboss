require 'puppet/provider/jbosscli'

Puppet::Type.type(:securitydomain).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  commands :jbosscli => "#{Puppet::Provider::Jbosscli.jbossclibin}"
  def create

    cmd = "/profile=default/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add(login-modules=[{code=>\"#{@resource[:code]}\",flag=>\"#{@resource[:codeflag]}\",module-options=>["
    @resource[:moduleoptions].each_with_index do |(key, value), index|
      cmd += "#{key}=>\"#{value}\""
      if index == @resource[:moduleoptions].length - 1
      break
      end
      cmd += ","
    end
    cmd += "]}])"
    execute("/profile=default/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)")[:result]
    return execute(cmd)[:result]
  end

  def destroy
    cmd = "/profile=default/subsystem=security/security-domain=#{@resource[:name]}:remove()"
    return execute(cmd)[:result]
  end

  #
  def exists?
    res = execute("/profile=default/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:read-resource()")

    if res == false
    return false
    end

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
        givenmoduleoptionshash["#{key}"] = "#{value}"
      end
    end

    i = 0

    while i < existingmodulessize  do
      k = b["result"]['login-modules'][0]['module-options'][i].keys
      v = b["result"]['login-modules'][0]['module-options'][i].values
      existingmoduleoptionshash["#{k}"] = "#{v}"
      i += 1
    end

    if !existingmoduleoptionshash.nil? && !givenmoduleoptionshash.nil? && existingmoduleoptionshash != givenmoduleoptionshash
      destroy
    return false
    end
    return true
  end
end
