# Internal class - manage JBoss service
class jboss::internal::service {

  include jboss
  include jboss::params
  include jboss::internal::configuration
  include jboss::internal::params

  Exec {
    path      => $jboss::internal::params::syspath,
    logoutput => 'on_failure',
  }

  anchor { 'jboss::service::begin': }

  $servicename = $jboss::product
  # TODO: change to $::virtual after dropping support for Puppet 2.x
  $enable = $::jboss_virtual ? {
    'docker' => undef,
    default  => true,
  }

  service { $servicename:
    ensure     => running,
    enable     => $enable,
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
