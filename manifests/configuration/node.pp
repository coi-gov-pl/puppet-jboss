define jboss::configuration::node (
  $path        = $name,
  $properties  = undef,
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
  
  jboss_confignode { $name:
    ensure      => $ensure,
    path        => $path,
    properties  => $properties,
    controller  => $controller,
    profile     => $profile,
    runasdomain => $realrunasdomain,
    notify      => Exec['jboss::service::restart'],
    require     => Anchor['jboss::service::end'],
  }
  
}