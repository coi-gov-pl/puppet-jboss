define jboss::configuration::node (
  $path        = $name,
  $properties  = undef,
  $ensure      = 'present',
  $profile     = hiera('jboss::settings::profile', 'full-ha'),
  $controller  = hiera('jboss::settings::controller', 'localhost:9999'),
  $runasdomain = undef,
  $dorestart   = true,
) {
  include jboss
  
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