# Internal class - manage JBoss service
class jboss::internal::service {
  include jboss
  $servicename = $jboss::product

  include jboss::params
  include jboss::internal::params
  include jboss::internal::compatibility
  include jboss::internal::configuration
  include jboss::internal::quirks::etc_initd_functions
  include jboss::internal::prerequisites

  Exec {
    path      => $jboss::internal::params::syspath,
    logoutput => 'on_failure',
  }

  anchor { 'jboss::service::begin': }

  $service_stop_cooldown = 5 # sec.
  # TODO: change to $::virtual after dropping support for Puppet 2.x
  $enable = $::virtual ? {
    'docker' => undef,
    default  => true,
  }

  if $jboss::internal::compatibility::initsystem == 'SystemD' {
    exec { "systemctl-daemon-reload-for-${servicename}":
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
      notify      => Service[$servicename],
      subscribe   => [
        Anchor['jboss::package::end'],
        Anchor['jboss::configuration::end'],
        Anchor['jboss::service::begin'],
      ],
    }
  }

  service { $servicename:
    ensure     => running,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [
      Package['coreutils'],
      Anchor['jboss::package::end'],
      Anchor['jboss::service::begin'],
    ],
  }

  if $jboss::internal::compatibility::expect_to_start {
    $test_running_loglevel   = 'emerg'
    $test_running_failstatus = 1
  } else {
    $test_running_loglevel   = 'warning'
    $test_running_failstatus = 0
  }

  exec { 'jboss::service::test-running':
    loglevel  => $test_running_loglevel,
    command   => "tail -n 80 ${jboss::internal::configuration::logfile} && exit ${test_running_failstatus}",
    unless    => "pgrep -f '^java.*${servicename}' > /dev/null",
    logoutput => true,
    subscribe => Service[$servicename],
    require   => Package['procps'],
  }

  $restart_cmd1 = $jboss::internal::compatibility::initsystem ? {
    'SystemD' => "systemctl stop ${servicename}",
    default   => "service ${servicename} stop"
  }
  $restart_cmd2 = "sleep ${service_stop_cooldown}"
  $restart_cmd3 = "pkill -9 -f '^java.*${servicename}'"
  $restart_cmd4 = $jboss::internal::compatibility::initsystem ? {
    'SystemD' => "systemctl start ${servicename}",
    default   => "service ${servicename} start"
  }

  exec { 'jboss::service::restart':
    command     => "${restart_cmd1} ; ${restart_cmd2} ; ${restart_cmd3} ; ${restart_cmd4}",
    refreshonly => true,
    require     => [
      Package['procps'],
      Exec['jboss::service::test-running'],
    ],
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
