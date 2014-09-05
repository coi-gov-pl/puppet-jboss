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
  include jboss::internal::service
  
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
    require              => Anchor['jboss::package::end'],
  }

  if str2bool($::jboss_running) {
    Jboss_resourceadapter[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_resourceadapter[$name] ~> Exec['jboss::service::restart']
  }
} 