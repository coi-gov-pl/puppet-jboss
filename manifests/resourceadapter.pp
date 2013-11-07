define jboss::resourceadapter (
  $ensure                  = 'present',
  $jndiname,
  $archive,
  $transactionsupport,
  $classname,
  $security                = hiera('jboss::resourceadapter::security', 'application'),
  $backgroundvalidation    = hiera('jboss::resourceadapter::backgroundvalidation', false),
  $profile                 = hiera('jboss::settings::profile', 'full-ha'),
  $controller              = hiera('jboss::settings::controller', 'localhost:9999'),
  $runasdomain             = undef,
) {
  include jboss
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
  
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
    runasdomain          => $realrunasdomain,
    require              => Anchor['jboss::service::end'],
    notify               => Exec['jboss::service::restart'],
  }
} 