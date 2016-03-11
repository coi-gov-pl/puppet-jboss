module Testing::Acceptance::Cleaner
  def remove_jboss_installation(serv)
    shell "service #{serv} stop"
    rm_sprecs = [
      '/usr/lib', '/etc', '/etc/init.d',
      '/etc/sysconfig', '/etc/default', '/var/log'
    ].map { |e| "#{e}/#{serv}*" }.join(' ')
    shell "rm -rf #{rm_sprecs} /etc/jboss-as /etc/profile.d/jboss.sh"
  end
end
