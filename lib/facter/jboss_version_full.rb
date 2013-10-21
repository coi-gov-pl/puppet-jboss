Facter.add(:jboss_version_full) do
  setcode do
    out = nil
    home = Facter.value(:jboss_home)
    begin
      if home.nil?
        raise Exception, 'JBoss is not installed!'
      end
      file = File.open("%s/version.txt" % home, "rb")
      version = file.read.chomp
      out = version
    rescue Exception => e
      out = nil
    end
    out
  end
end