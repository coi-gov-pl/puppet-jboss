module Testing::Acceptance::Cleaner
  def remove_jboss_installation(serv)
    shell "service #{serv} stop"
    shell "rm -rf /usr/lib/#{serv}*"
    shell "rm -rf /etc/#{serv}*"
    shell "rm -rf /etc/init.d/#{serv}*"
    shell "rm -rf /etc/default/#{serv}*"
    shell "rm -rf /etc/sysconfig/#{serv}*"
    shell "rm -rf /var/log/#{serv}*"
  end
end
