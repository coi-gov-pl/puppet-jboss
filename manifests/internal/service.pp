# Internal class - manage JBoss service
class jboss::internal::service {

  include jboss
  include jboss::params
  include jboss::internal::configuration

  Exec {
    path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    logoutput => 'on_failure',
  }

  anchor { 'jboss::service::begin': }

  $servicename = $jboss::product

  service { $servicename:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [
      Anchor['jboss::package::end'],
      Anchor['jboss::service::begin'],
    ],
  }

  exec { 'jboss::service::test-running':
    loglevel  => 'emerg',
    command   => "tail -n 50 ${jboss::internal::configuration::logfile} && exit 1",
    unless    => "ps aux | grep ${servicename} | grep -vq grep",
    logoutput => true,
    subscribe => Service[$servicename],
  }

  exec { 'jboss::service::restart':
    command     => "service ${servicename} stop ; pkill -9 -f \"^java.*jboss\"  ; service ${servicename} start",
    refreshonly => true,
    require     => Exec['jboss::service::test-running'],
  }

  anchor { 'jboss::service::end':
    require => [
      Service[$servicename],
      Exec['jboss::service::test-running'],
    ],
  }

  anchor { 'jboss::service::started':
    require => [
      Service[$servicename],
      Anchor['jboss::service::end'],
      Exec['jboss::service::restart'],
    ],
  }
}
