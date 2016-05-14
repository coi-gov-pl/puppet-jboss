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

  $servicescriptpath = $jboss::superuser ? {
    true    => undef,
    default => $jboss::internal::compatibility::full_initd_file
  }

  service { $servicename:
    ensure     => running,
    enable     => $enable,
    path       => $servicescriptpath,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [
      Anchor['jboss::package::end'],
      Anchor['jboss::service::begin'],
    ],
    before     => [
      Anchor['jboss::service::end'],
      Anchor['jboss::service::started'],
    ],
  }

  exec { 'jboss::service::test-running':
    loglevel  => 'emerg',
    command   => "tail -n 50 ${jboss::internal::configuration::logfile} && exit 1",
    unless    => "ps aux | grep ${servicename} | grep -vq grep",
    logoutput => true,
    subscribe => Service[$servicename],
    before    => Anchor['jboss::service::end'],
  }

  exec { 'jboss::service::restart':
    command     => "service ${servicename} stop ; pkill -9 -f \"^java.*jboss\"  ; service ${servicename} start",
    refreshonly => true,
    require     => Exec['jboss::service::test-running'],
    before      => Anchor['jboss::service::started'],
  }

  anchor { 'jboss::service::end': }
  anchor { 'jboss::service::started':
    require => Anchor['jboss::service::end'],
  }
}
