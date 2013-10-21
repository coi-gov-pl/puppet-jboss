Facter.add(:jboss_version) do
  setcode do
    out = nil
    full = Facter.value(:jboss_version_full)
    begin
      if full.nil?
        raise Exception, 'JBoss is not installed!'
      end
      re = /([0-9]+\.[0-9]+\.[0-9]+[\._-][0-9a-zA-Z_-]+)/
      match = full.match re
      version = match.captures[0].chomp
      eap = false
      if full.match(/Enterprise Application Platform/)
        eap = true
      end
      desc = case eap
        when true then 'eap'
        else 'as'
      end
      out = '%s-%s' % [desc, version]
    rescue Exception => e
      out = nil
    end
    out
  end
end