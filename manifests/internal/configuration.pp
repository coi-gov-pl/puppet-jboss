class jboss::internal::configuration {
  include jboss
  include jboss::params
  include jboss::internal::params
  include jboss::internal::runtime
  include jboss::internal::lenses
  include jboss::internal::configure::interfaces

  $home          = $jboss::home
  $user          = $jboss::jboss_user
  $logfile       = $jboss::internal::params::logfile
  $enableconsole = $jboss::enableconsole
  $runasdomain   = $jboss::runasdomain
  $controller    = $jboss::controller
  $profile       = $jboss::profile
  $configfile    = $jboss::internal::runtime::configfile


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
        Service['jboss'],
      ],
    }
  }

  concat { '/etc/jboss-as/jboss-as.conf':
    alias   => 'jboss::jboss-as.conf',
    mode    => 644,
    notify  => Service['jboss'],
    require => Anchor['jboss::configuration::begin'],
  }


  concat::fragment { 'jboss::jboss-as.conf::defaults':
    target  => '/etc/jboss-as/jboss-as.conf',
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
