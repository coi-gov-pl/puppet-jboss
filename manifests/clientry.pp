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
    profile     => $profile,
    runasdomain => $runasdomain,
    require     => Anchor['jboss::service::end'],
  }
  
  if $dorestart {
    Jboss_confignode[$name] ~> Exec['jboss::service::restart']
  }
  
}