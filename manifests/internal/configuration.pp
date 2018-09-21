# == Class: jboss::internal::configure
#
class jboss::internal::configuration {
  include jboss
  include jboss::params
  include jboss::internal::params
  include jboss::internal::runtime
  include jboss::internal::augeas
  include jboss::internal::configure::interfaces
  include jboss::internal::configure::environmental

  $home          = $jboss::home
  $user          = $jboss::jboss_user
  $enableconsole = $jboss::enableconsole
  $runasdomain   = $jboss::runasdomain
  $controller    = $jboss::controller
  $profile       = $jboss::profile
  $configfile    = $jboss::internal::runtime::configfile
  $product       = $jboss::product
  $version       = $jboss::version
  $etcconfdir    = "/etc/${jboss::product}"
  $conffile      = "${etcconfdir}/${jboss::product}.conf"
  $logdir        = "${jboss::internal::params::logbasedir}/${jboss::product}"
  $logfile       = "${logdir}/console.log"

  anchor { 'jboss::configuration::begin':
    require => Anchor['jboss::package::end'],
  }

  if $runasdomain {
    include jboss::internal::service
    $hostfile = "${jboss::home}/domain/configuration/host.xml"
    $augeas = merge($jboss::internal::augeas::defaults, {
      changes   => "set host/#attribute/name ${jboss::hostname}",
      context   => "/files${hostfile}/",
      incl      => $hostfile,
    })
    create_resources('augeas', { "jboss::configure::set_hostname(${jboss::hostname})" => $augeas })
  }

  file { '/etc/profile.d/jboss.sh':
    ensure  => 'file',
    mode    => '0644',
    content => "export JBOSS_CONF='${conffile}'",
    before  => Concat[$conffile],
  }

  file { $logdir:
    ensure => 'directory',
    alias  => 'jboss::logdir',
    mode   => '2770',
    owner  => $user,
    group  => $jboss::jboss_group,
  }

  file { $logfile:
    ensure => 'file',
    alias  => 'jboss::logfile',
    owner  => 'root',
    group  => $jboss::jboss_group,
    mode   => '0660',
  }

  if $jboss::product != 'jboss-as' {
    file { '/etc/jboss-as':
      ensure => 'directory',
      owner  => $user,
      group  => $jboss::jboss_group,
      mode   => '2770',
    }
    file { '/etc/jboss-as/jboss-as.conf':
      ensure => 'link',
      target => $conffile,
      before => Anchor['jboss::configuration::end'],
    }
  }

  $defaults_file = $::osfamily ? {
    'Debian' => "/etc/default/${jboss::product}",
    'RedHat' => "/etc/sysconfig/${jboss::product}.conf",
    default  => undef
  }
  if $defaults_file == undef {
    fail("Unsupported OS Family: ${::osfamily}")
  }

  file { '/etc/default':
    ensure => 'directory',
  }

  file { [$defaults_file, "/etc/default/${jboss::product}.conf"]:
    ensure => 'link',
    target => $conffile,
    before => Anchor['jboss::configuration::end'],
  }

  concat { $conffile:
    alias   => 'jboss::jboss-as.conf',
    mode    => '0644',
    notify  => Service[$jboss::product],
    require => [
      Anchor['jboss::configuration::begin'],
      File[$logdir],
    ],
  }

  concat::fragment { 'jboss::jboss-as.conf::defaults':
    target  => $conffile,
    order   => '000',
    content => template('jboss/jboss-as.conf.erb'),
  }

  anchor { 'jboss::configuration::end':
    require => [
      Anchor['jboss::configuration::begin'],
      Concat['jboss::jboss-as.conf'],
    ],
  }
}
