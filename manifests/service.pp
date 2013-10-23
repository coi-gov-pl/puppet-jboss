class jboss::service {

  Exec {
    path      => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    logoutput => 'on_failure',
  }
  
  anchor { "jboss::service::begin": }
  
  $servicename = 'jboss'
  
  service { $servicename:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Anchor["jboss::package::end"],
      Anchor['jboss::service::begin'],
    ],
  }
  
  exec { 'jboss::service::test-running':
    command     => "ps aux | grep ${servicename} | grep -vq grep || ( tail -n 50 /var/log/jboss-as/console.log && exit 1 )",
    logoutput   => true,
    refreshonly => true,
    subscribe   => Service['jboss'],
  }
  
  anchor { "jboss::service::end": 
    require => [
      Service[$servicename],
      Exec['jboss::service::test-running'],
    ], 
  }
}