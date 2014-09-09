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
  include jboss::internal::service
  include jboss::internal::runtime::node
  
  jboss_jmsqueue { $name:
    durable       => $durable,
    entries       => $entries,
    ensure        => $ensure,
    runasdomain   => $runasdomain,
    profile       => $profile,
    controller    => $controller,
    ctrluser      => $jboss::internal::runtime::node::username,
    ctrlpasswd    => $jboss::internal::runtime::node::password,
    require       => Anchor['jboss::package::end'],
  }

  if str2bool($::jboss_running) {
    Jboss_jmsqueue[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_jmsqueue[$name] ~> Exec['jboss::service::restart']
  }
}