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
    loglevel    => 'emerg',
    command     => 'tail -n 50 /var/log/jboss-as/console.log && exit 1',
    unless      => "ps aux | grep ${servicename} | grep -vq grep",
    logoutput   => true,
    subscribe   => Service['jboss'],
  }
  
  exec { 'jboss::service::restart':
    command     => 'service jboss restart',
    refreshonly => true,
    require     => Exec['jboss::service::test-running'],
  }
  
  anchor { "jboss::service::end": 
    require => [
      Service[$servicename],
      Exec['jboss::service::test-running'],
    ], 
  }
  
  anchor { "jboss::service::started": 
    require => [
      Service[$servicename],
      Anchor["jboss::service::end"], 
      Exec['jboss::service::restart'],
    ], 
  }
}