class jboss::service {
  service { 'jboss':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Class['java'],
      Exec['jboss-service-link'],
      Setgroupaccess['set-perm'],
      File['jboss-as-conf'],
      Anchor["jboss::installed"],
    ],
  }
}