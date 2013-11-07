define jboss::configuration::property (
  $path,
  $key         = $name,
  $value       = undef,
  $ensure      = 'present',
  $profile     = hiera('jboss::settings::profile', 'full-ha'),
  $controller  = hiera('jboss::settings::controller', 'localhost:9999'),
  $runasdomain = undef,
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
    notify      => Exec['jboss::service::restart'],
    require     => Anchor['jboss::service::end'],
  }
}