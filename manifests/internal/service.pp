# Internal class - manage JBoss service
class jboss::internal::service {
  include jboss
  $servicename = $jboss::product

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

  # TODO: change to $::virtual after dropping support for Puppet 2.x
  if $::jboss_virtual == 'docker' and $jboss::internal::compatibility::initsystem == 'SystemV' {
    $enable = undef
  } else {
    $enable = true
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

  $errloglines = $jboss::internal::params::errloglines
  $logfile     = $jboss::internal::configuration::logfile

  exec { 'jboss::service::test-running':
    loglevel  => $test_running_loglevel,
    command   => "tail -n ${errloglines} ${logfile} && exit ${test_running_failstatus}",
    unless    => "sleep 1 && pgrep -f 'java.*${jboss::home}' > /dev/null",
    logoutput => true,
    subscribe => Service[$servicename],
    require   => Package['procps'],
  }

  exec { 'jboss::service::restart':
    command     => "${jboss::home}/bin/restart.sh",
    refreshonly => true,
    logoutput   => true,
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
