Facter.add(:jboss_home) do
  setcode do
    out = nil
    begin
      file = File.open("/etc/jboss-as/jboss-as.conf", "rb")
      contents = file.read
      re = /JBOSS_HOME=(.+?)\n/
      match = contents.match re
      home = match.captures[0].chomp
      if File.file?("%s/bin/jboss-cli.sh" % home)
        out = home
      else
        out = nil
      end
    rescue Exception => e
      out = nil
    end
    out
  end
end
