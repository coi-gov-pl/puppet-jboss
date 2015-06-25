class jboss::internal::configuration {
  include jboss
  include jboss::params
  include jboss::internal::params
  include jboss::internal::runtime
  include jboss::internal::lenses
  include jboss::internal::configure::interfaces

  $home          = $jboss::home
  $user          = $jboss::jboss_user
  $enableconsole = $jboss::enableconsole
  $runasdomain   = $jboss::runasdomain
  $controller    = $jboss::controller
  $profile       = $jboss::profile
  $configfile    = $jboss::internal::runtime::configfile
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
    augeas { "jboss::configure::set_hostname(${jboss::hostname})":
      load_path => $jboss::internal::lenses::lenses_path,
      lens      => 'jbxml.lns',
      changes   => "set host/#attribute/name ${jboss::hostname}",
      context   => "/files${hostfile}/",
      incl      => $hostfile,
      require   => [
        Anchor['jboss::configuration::begin'],
        Anchor['jboss::package::end'],
        File["${jboss::internal::lenses::lenses_path}/jbxml.aug"],
      ],
      notify    => [
        Anchor['jboss::configuration::end'],
        Service[$jboss::product],
      ],
    }
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
