define jboss::datasource (
  $username,
  $password,
  $driver,
  $connection              = undef,
  $ensure                  = 'present',
  $jndiname                = "java:jboss/datasources/${name}",
  $jta                     = hiera('jboss::datasource::jta', true),
  $profile                 = hiera('jboss::datasource::profile', 'full-ha'),
  $controller              = hiera('jboss::datasource::controller', 'localhost:9999'),
  $minpoolsize             = hiera('jboss::datasource::minpoolsize', 1),
  $maxpoolsize             = hiera('jboss::datasource::maxpoolsize', 50),
  $validateonmatch         = hiera('jboss::datasource::validateonmatch', false),
  $backgroundvalidation    = hiera('jboss::datasource::backgroundvalidation', false),
  $sharepreparedstatements = hiera('jboss::datasource::sharepreparedstatements', false),
  $enabled                 = hiera('jboss::datasource::enabled', true),
  $runasdomain             = undef,
  $baseconnection          = undef,
) {
  include jboss
  
  if $baseconnection == undef and $connection == undef {
    fail('Provide at least one of $baseconnection or $connection')
  }
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
  
  $realconnection = $connection ? {
    undef   => "${baseconnection}/${name}",
    default => $connection,
  }
  
  $drivername = $driver['name']
  
  if ! defined(Jboss_jdbcdriver[$drivername]) and $ensure == 'present' {
    jboss_jdbcdriver { $drivername:
      ensure              => 'present',
      classname           => $driver['classname'],
      modulename          => $driver['modulename'],
      datasourceclassname => $driver['datasourceclassname'],
      runasdomain         => $realrunasdomain,
      profile             => $profile,
      controller          => $controller,
      require             => Anchor['jboss::service::end'],
      notify              => Exec['jboss::service::restart'],
    }
  }
  
  datasource { $name:
    ensure                  => $ensure,
    enabled                 => $enabled,
    runasdomain             => $realrunasdomain,
    profile                 => $profile,
    controller              => $controller,
    jndiname                => $jndiname,
    jta                     => $jta,
    drivername              => $drivername,
    minpoolsize             => $minpoolsize,
    maxpoolsize             => $maxpoolsize,
    username                => $username,
    password                => $password,
    validateonmatch         => $validateonmatch,
    backgroundvalidation    => $backgroundvalidation,
    sharepreparedstatements => $sharepreparedstatements,
    xadatasourceproperties  => $realconnection,
    notify                  => Exec['jboss::service::restart'],
    require                 => [
      Anchor['jboss::service::end'],
      Jboss_jdbcdriver[$drivername],
    ],
  }
}