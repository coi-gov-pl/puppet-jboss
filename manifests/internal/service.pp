# Internal class - manage JBoss service
class jboss::internal::service {

  include jboss
  include jboss::params
  include jboss::internal::params
  include jboss::internal::compatibility
  include jboss::internal::configuration
  include jboss::internal::quirks::etc_initd_functions

  Exec {
    path      => $jboss::internal::params::syspath,
    logoutput => 'on_failure',
  }

  anchor { 'jboss::service::begin': }

  $service_start_cooldown = 5 # sec.
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
  }

  exec { 'jboss::service::restart':
    command     => "service ${servicename} stop ; sleep 5 ; pkill -9 -f '^java.*${servicename}' ; service ${servicename} start",
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
