# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss

module Provider
# A class for JBoss configuration
module SecurityDomain
    def create
      cmd = "/subsystem=security/security-domain=#{@resource[:name]}/authentication=classic:add(login-modules=[{code=>\"#{@resource[:code]}\",flag=>\"#{@resource[:codeflag]}\",module-options=>["
      options = []
      @resource[:moduleoptions].keys.sort.each do |key|
        value = @resource[:moduleoptions][key]
        val = value.to_s.gsub(/\n/, ' ').strip
        options << '%s => "%s"' % [key, val]
      end
      cmd += options.join(',') + "]}])"
      cmd = compilecmd(cmd)
      cmd2 = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:add(cache-type=default)"
      bringUp('Security Domain Cache Type', cmd2)[:result]
      bringUp('Security Domain', cmd)[:result]
    end

    def destroy
      cmd = compilecmd "/subsystem=security/security-domain=#{@resource[:name]}:remove()"
      bringDown('Security Domain', cmd)[:result]
    end

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
    def preparelines lines
      lines.gsub(/\((\"[^\"]+\") => (\"[^\"]+\")\)/, '\1 => \2').gsub(/\[((?:[\n\s]*\"[^\"]+\" => \"[^\"]+\",?[\n\s]*)+)\]/m, '{\1}')
    end
  end
end
end
end
end
