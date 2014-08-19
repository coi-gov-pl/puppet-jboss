/**
 * Creates JBoss resource adapter
 */
define jboss::resourceadapter (
  $ensure                  = 'present',
  $jndiname,
  $archive,
  $transactionsupport,
  $classname,
  $security                = hiera('jboss::resourceadapter::security', 'application'),
  $backgroundvalidation    = hiera('jboss::resourceadapter::backgroundvalidation', false),
  $profile                 = $::jboss::profile,
  $controller              = $::jboss::controller,
  $runasdomain             = $::jboss::runasdomain,
) {
  include jboss
  
  jboss_resourceadapter { $name:
    ensure               => $ensure,
    archive              => $archive,
    transactionsupport   => $transactionsupport,
    backgroundvalidation => $backgroundvalidation,
    security             => $security,
    classname            => $classname,
    jndiname             => $jndiname,
    controller           => $controller,
    profile              => $profile,
    runasdomain          => $runasdomain,
    require              => Anchor['jboss::service::end'],
    notify               => Exec['jboss::service::restart'],
  }
} 