# == Define: jboss::resourceadapter
#
# This defined type can be used to add and remove JBoss resource adapters. A resource adapter
# is a deployable Java EE component that provides communication between a Java EE application
# and an Enterprise Information System (EIS) using the Java Connector Architecture (JCA)
# specification
#
# See here: https://docs.oracle.com/javaee/6/tutorial/doc/bncjh.html
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*name*]
#     **This is the namevar**. The name/ID of resource adapter.
# [*jndiname*]
#     **Required parameter.** The resource adapter jndi name of connection definition.
# [*archive*]
#     **Required parameter.** The resource adapter archive.
# [*transactionsupport*]
#     **Required parameter.** The resource adapter transaction support type. Valid values are: *NoTransation*,
#     *LocalTransaction*, *XATransaction*
# [*classname*]
#     **Required parameter.** The resource adapter connection definition class name.
# [*ensure*]
#     Standard Puppet ensure parameter with values: 'present' and 'absent'
# [*security*]
#     Security type. By default it is set to 'application' value
# [*backgroundvalidation*]
#     Do use background validation feature. By default it is set to false.
#
define jboss::resourceadapter (
  $jndiname,
  $archive,
  $transactionsupport,
  $classname,
  $ensure                  = 'present',
  $security                = hiera('jboss::resourceadapter::security', 'application'),
  $backgroundvalidation    = jboss_to_bool(hiera('jboss::resourceadapter::backgroundvalidation', false)),
  $profile                 = $::jboss::profile,
  $controller              = $::jboss::controller,
  $runasdomain             = $::jboss::runasdomain,
) {
  include jboss
  include jboss::internal::service
  include jboss::internal::runtime::node

  jboss_resourceadapter { $name:
    ensure               => $ensure,
    archive              => $archive,
    transactionsupport   => $transactionsupport,
    backgroundvalidation => $backgroundvalidation,
    security             => $security,
    classname            => $classname,
    jndiname             => $jndiname,
    controller           => $controller,
    ctrluser             => $jboss::internal::runtime::node::username,
    ctrlpasswd           => $jboss::internal::runtime::node::password,
    profile              => $profile,
    runasdomain          => $runasdomain,
    require              => Anchor['jboss::package::end'],
  }

  if jboss_to_bool($::jboss_running) {
    Jboss_resourceadapter[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_resourceadapter[$name] ~> Exec['jboss::service::restart']
  }
}
