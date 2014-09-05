require File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'jbosscli.rb'))

Puppet::Type.type(:jboss_securitydomain).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do

  def create
    cmd = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add(login-modules=[{code=>\"#{@resource[:code]}\",flag=>\"#{@resource[:codeflag]}\",module-options=>["
    @resource[:moduleoptions].each_with_index do |(key, value), index|
      val = value.to_s.gsub(/\n/, ' ').strip
      cmd += '%s => "%s"' % [key, val]
      if index == @resource[:moduleoptions].length - 1
        break
      end
      cmd += ","
    end
    cmd += "]}])"
    cmd2 = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)"
    bringUp('Security Domain Cache Type', cmd2)[:result]
    bringUp('Security Domain', cmd)[:result]
  end

  def destroy
    cmd = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:remove()"
    bringDown('Security Domain', cmd)[:result]
  end

  def preparelines lines
    lines.gsub(/\((\"[^\"]+\") => (\"[^\"]+\")\)/, '\1 => \2').gsub(/\[((?:[\n\s]*\"[^\"]+\" => \"[^\"]+\",?[\n\s]*)+)\]/m, '{\1}')
  end

  #
  def exists?
    cmd = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:read-resource()"
    res = executeWithoutRetry cmd
    if not res[:result]
      Puppet.debug "Security Domain does NOT exist"
      return false
    end
    undefined = nil
    lines = preparelines res[:lines]
    data = eval(lines)['result']
    Puppet.debug "Security Domain exists: #{data.inspect}"

    existinghash = Hash.new
    givenhash = Hash.new

    if !@resource[:moduleoptions].nil?
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
  
end
