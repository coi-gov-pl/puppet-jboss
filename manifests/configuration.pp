class jboss::configuration {
  include jboss
  include jboss::params
  include jboss::params::internal
  
  $home          = $jboss::home
  $user          = $jboss::jboss_user
  $logfile       = $jboss::params::internal::logfile
  $enableconsole = $jboss::enableconsole
  $runasdomain   = $jboss::runasdomain
  $controller    = $jboss::controller
  $profile       = $jboss::profile
  
  anchor { "jboss::configuration::begin":
    require => Anchor['jboss::package::end'],
  }
  
  concat { '/etc/jboss-as/jboss-as.conf':
    alias   => 'jboss::jboss-as.conf',
    mode    => 644,
    notify  => Service["jboss"],
    require => Anchor["jboss::configuration::begin"],
  }
  if $enableconsole {
    $manageprops = {
      'inet-address' => undef,
      'any-address'  => true,
    }
  } else {
    $manageprops = {
      'inet-address' => "\${jboss.bind.address.management:127.0.0.1}",
      'any-address'  => undef,
    }
  }

  jboss::configuration::node { 'jboss::configuration::management::inet-address':
    ensure     => 'present',
    path       => '/host=master/interface=management',
    properties => {
      'inet-address' => $manageprops['inet-address'],
    },
  }
  jboss::configuration::node { 'jboss::configuration::management::any-address':
    ensure     => 'present',
    path       => '/host=master/interface=management',
    properties => {
      'any-address'  => $manageprops['any-address'],
    },
  }
  
  if $enableconsole {
    Jboss::Configuration::Node['jboss::configuration::management::inet-address'] ->
    Jboss::Configuration::Node['jboss::configuration::management::any-address']
  } else {
    Jboss::Configuration::Node['jboss::configuration::management::any-address'] ->
    Jboss::Configuration::Node['jboss::configuration::management::inet-address']
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