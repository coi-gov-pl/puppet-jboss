/**
 * 
 */
define jboss::configuration::property (
  $key,
  $path        = $name,
  $value       = undef,
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
  
  jboss_configproperty { $name:
    ensure      => $ensure,
    key         => $key,
    value       => $value,
    path        => $path,
    controller  => $controller,
    profile     => $profile,
    runasdomain => $realrunasdomain,
    require     => Anchor['jboss::service::end'],
  }
  
  if $dorestart {
    Jboss_configproperty[$name] ~> Exec['jboss::service::restart']
  }
}