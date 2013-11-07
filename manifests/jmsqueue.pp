/**
 * Creates JBoss JMS Queue 
 */
define jboss::jmsqueue (
  $ensure       = 'present',
  $entries,
  $durable      = hiera('jboss::jmsqueue::durable', false),
  $profile      = hiera('jboss::settings::profile', 'full-ha'),
  $controller   = hiera('jboss::settings::controller','localhost:9999'),
  $runasdomain  = undef,
) {
  include jboss
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
  
  jboss_jmsqueue { $name:
    durable       => $durable,
    entries       => $entries,
    ensure        => $ensure,
    runasdomain   => $realrunasdomain,
    profile       => $profile,
    controller    => $controller,
    notify        => Exec['jboss::service::restart'],
    require       => [
      Anchor['jboss::service::end'],
    ],
  }
}