/**
 * Deployuje artefact na serwer 
 */
define jboss::deploy (
  $ensure       = 'present',
  $jndi         = $name,
  $path,
  $redeploy     = false,
  $servergroups = hiera('jboss::deploy::servergroups', undef),
  $controller   = hiera('jboss::deploy::controller','localhost:9999'),
  $runasdomain  = undef,
) {
  include jboss
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
  
  deploy { $jndi:
    ensure       => $ensure,
    source       => $path,
    runasdomain  => $realrunasdomain,
    redeploy     => $redeploy,
    servergroups => $servergroups,
    controller   => $controller,
    require      => [
      Anchor['jboss::service::end'],
      Exec['jboss::service::restart'],
    ],
  }
  
}
