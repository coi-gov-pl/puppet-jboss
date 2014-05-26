class jboss::internal::configuration {
  include jboss
  include jboss::params
  include jboss::internal::params
  include jboss::internal::runtime
  
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
    file_line { "jboss::configure::set_hostname(${jboss::hostname})":
      ensure    => "present",
      line      => "<host name=\"${jboss::hostname}\" xmlns=\"urn:jboss:domain:1.5\">",
      match     => "\\<host[^\\>]+\\>",
      path      => $hostfile,
      notify    => Service[$jboss::internal::service::servicename],
      before    => Anchor['jboss::configuration::begin'], 
      require   => Anchor['jboss::package::end'],
    }
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
  
  if $runasdomain {
    $managementPath = "/host=${jboss::hostname}/interface=management"
  } else {
    $managementPath = '/interface=management'
  }

  jboss::configuration::node { 'jboss::configuration::management::inet-address':
    ensure     => 'present',
    path       => $managementPath,
    properties => {
      'inet-address' => $manageprops['inet-address'],
    },
  }
  jboss::configuration::node { 'jboss::configuration::management::any-address':
    ensure     => 'present',
    path       => $managementPath,
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