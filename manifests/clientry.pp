include jboss::params

/**
 * Generic configuration tool
 */
define jboss::clientry (
  $path        = $name,
  $properties  = undef,
  $ensure      = 'present',
  $profile     = undef,
  $controller  = undef,
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
  
  if $realrunasdomain {
    $realprofile = $profile ? {
      undef   => $jboss::profile,
      default => $profile,
    }
    $realcontroller = $controller ? {
      undef   => $jboss::controller,
      default => $controller,
    }
  } else {
    $realprofile    = undef
    $realcontroller = undef
  }
  
  jboss_confignode { $name:
    ensure      => $ensure,
    path        => $path,
    properties  => $properties,
    controller  => $realcontroller,
    profile     => $realprofile,
    runasdomain => $realrunasdomain,
    require     => Anchor['jboss::service::end'],
  }
  
  if $dorestart {
    Jboss_confignode[$name] ~> Exec['jboss::service::restart']
  }
  
}