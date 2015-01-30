include jboss::params

/**
 * Generic configuration tool
 */
define jboss::clientry (
  $path        = $name,
  $properties  = undef,
  $ensure      = 'present',
  $profile     = $::jboss::profile,
  $controller  = $::jboss::controller,
  $runasdomain = $::jboss::runasdomain,
  $dorestart   = true,
) {
  include jboss
  include jboss::internal::service
  include jboss::internal::runtime::node
  
  case $ensure {
    'running':  {} 
    'stopped':  {}
    'absent':   {}
    'present':  {}
    'enabled':  {}
    'disabled': {}
    default:   {
      fail("Invalid value for ensure: `${ensure}`. Supported values are: `present`, `absent`, `running`, `stopped`, `enabled`, `disabled`")
    }
  }
  
  jboss_confignode { $name:
    ensure      => $ensure,
    path        => $path,
    properties  => $properties,
    controller  => $controller,
    ctrluser    => $jboss::internal::runtime::node::username,
    ctrlpasswd  => $jboss::internal::runtime::node::password,
    profile     => $profile,
    runasdomain => $runasdomain,
    require     => Anchor['jboss::package::end'],
  }

  if str2bool($::jboss_running) {
    Jboss_confignode[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_confignode[$name]
  }
  
  if $dorestart {
    if !$::jboss::runasdomain {
      Jboss_confignode[$name] ~> Exec['jboss::service::restart']
    }
  }
  
}