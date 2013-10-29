class jboss::configuration {
  include jboss
  include jboss::params::internal
  
  $home = $jboss::home
  $user = $jboss::jboss_user
  $logfile = $jboss::params::internal::logfile
  $enableconsole = $jboss::enableconsole
  
  anchor { "jboss::configuration::begin":
    require => Anchor['jboss::package::end'],
  }
  
  concat { '/etc/jboss-as/jboss-as.conf':
    alias   => 'jboss::jboss-as.conf',
    mode    => 644,
    notify  => Service["jboss"],
    require => Anchor["jboss::configuration::begin"],
  }
  
  concat::fragment { 'jboss::jboss-as.conf::defaults':
    target  => "/etc/jboss-as/jboss-as.conf",
    order   => '000',
    content => template('jboss/jboss-as.conf.erb'),
  }
  
  anchor { "jboss::configuration::end":
    require => [
      Anchor['jboss::configuration::begin'],
      Concat['jboss::jboss-as.conf'],
    ],
  }
}