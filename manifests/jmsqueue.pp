# == Define: jboss::jmsqueue
#
# Use this defined type to add and remove JBoss JMS Queues.
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*entries*]
#     A list of JNDI entries for JBoss JMS Queue. You can specify any number of entries from which your queue will be visible
#     inside your application.
# [*ensure*]
#     Standard ensure parameter. Can be either `present` or `absent`.
# [*durable*]
#     This parameter indicate that given JMS queue should be durable or not. By default this is equal to `false`.
#
define jboss::jmsqueue (
  $entries,
  $ensure      = 'present',
  $durable     = jboss_to_bool(hiera('jboss::jmsqueue::durable', false)),
  $profile     = $jboss::profile,
  $controller  = $jboss::controller,
  $runasdomain = $jboss::runasdomain,
) {
  include jboss
  include jboss::internal::service
  include jboss::internal::runtime::node

  jboss_jmsqueue { $name:
    ensure      => $ensure,
    durable     => $durable,
    entries     => $entries,
    runasdomain => $runasdomain,
    profile     => $profile,
    controller  => $controller,
    ctrluser    => $jboss::internal::runtime::node::username,
    ctrlpasswd  => $jboss::internal::runtime::node::password,
    require     => Anchor['jboss::package::end'],
  }

  if jboss_to_bool($::jboss_running) {
    Jboss_jmsqueue[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_jmsqueue[$name] ~> Exec['jboss::service::restart']
  }
}
