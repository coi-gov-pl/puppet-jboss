class jboss::service {

  Exec {
    path      => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    logoutput => 'on_failure',
  }
  
  anchor { "jboss::service::begin": }
  
  service { 'jboss':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Anchor["jboss::package::end"],
      Anchor['jboss::service::begin'],
    ],
  }
  
  anchor { "jboss::service::end": 
    require => Service['jboss'], 
  }
}