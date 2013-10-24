/**
 * Deployuje artefact na serwer 
 */
define jboss::deploy (
  $ensure       = 'present',
  $jndi         = $name,
  $path,
  $runasdomain  = hiera('jboss::deploy::runasdomain', true),
  $redeploy     = false,
  $servergroups = hiera('jboss::deploy::servergroups', undef),
  $controller   = hiera('jboss::deploy::controller','localhost:9999'),
) {
  
  deploy { $jndi:
    ensure       => $ensure,
    source       => $path,
    runasdomain  => $runasdomain,
    redeploy     => $redeploy,
    servergroups => $servergroups,
    controller   => $controller,
    require      => Anchor['jboss::service::end'],
  }
  
}
