class jboss::configuration {
  include jboss
  
  $home = $jboss::home
  
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