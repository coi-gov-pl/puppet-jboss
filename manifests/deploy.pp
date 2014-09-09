/**
 * Deployuje artefact na serwer 
 */
define jboss::deploy (
  $ensure       = 'present',
  $jndi         = $name,
  $path,
  $redeploy     = false,
  $servergroups = hiera('jboss::deploy::servergroups', undef),
  $controller   = $::jboss::controller,
  $runasdomain  = $::jboss::runasdomain,
) {
  include jboss
  include jboss::internal::runtime::node
  
  jboss_deploy { $jndi:
    ensure       => $ensure,
    source       => $path,
    runasdomain  => $runasdomain,
    redeploy     => $redeploy,
    servergroups => $servergroups,
    controller   => $controller,
    ctrluser     => $jboss::internal::runtime::node::username,
    ctrlpasswd   => $jboss::internal::runtime::node::password,
    require      => [
      Anchor['jboss::service::end'],
      Exec['jboss::service::restart'],
    ],
  }
  
}
