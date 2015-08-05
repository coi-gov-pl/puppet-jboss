Facter.add(:jboss_configfile) do
  setcode do
    begin
      path = '/etc/profile.d/jboss.sh'
      content = File.read(path).chomp
      re = /export JBOSS_CONF=\'([^\']+)\'/
      m = re.match(content)
      m[1]
    rescue
      ENV['JBOSS_CONF']
    end
  end
end