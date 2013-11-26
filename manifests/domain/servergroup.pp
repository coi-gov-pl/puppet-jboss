define jboss::domain::servergroup (
  $name,
  $ensure                  = 'present',
  $profile                 = hiera('jboss::settings::profile', 'full-ha'),
  $controller              = hiera('jboss::settings::controller', 'localhost:9999'),
  $runasdomain             = undef, 
) {
  include jboss
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
}