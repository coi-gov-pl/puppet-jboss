/**
 * Creates JBoss JMS Queue 
 */
define jboss::jmsqueue (
  $ensure       = 'present',
  $entries,
  $durable      = hiera('jboss::jmsqueue::durable', false),
  $profile      = $::jboss::profile,
  $controller   = $::jboss::controller,
  $runasdomain  = $::jboss::runasdomain,
) {
  include jboss
  
  jboss_jmsqueue { $name:
    durable       => $durable,
    entries       => $entries,
    ensure        => $ensure,
    runasdomain   => $runasdomain,
    profile       => $profile,
    controller    => $controller,
    notify        => Exec['jboss::service::restart'],
    require       => [
      Anchor['jboss::service::end'],
    ],
  }
}