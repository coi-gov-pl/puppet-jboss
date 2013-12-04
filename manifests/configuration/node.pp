include jboss::params

/**
 * Generic configuration tool
 */
define jboss::configuration::node (
  $path        = $name,
  $properties  = undef,
  $ensure      = 'present',
  $profile     = $jboss::params::profile,
  $controller  = $jboss::params::controller,
  $runasdomain = undef,
  $dorestart   = true,
) {
  include jboss
  
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
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
  
  jboss_confignode { $name:
    ensure      => $ensure,
    path        => $path,
    properties  => $properties,
    controller  => $controller,
    profile     => $profile,
    runasdomain => $realrunasdomain,
    require     => Anchor['jboss::service::end'],
  }
  
  if $dorestart {
    Jboss_confignode[$name] ~> Exec['jboss::service::restart']
  }
  
}