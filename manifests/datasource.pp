define jboss::datasource (
  $username,
  $password,
  $jdbcscheme,
  $host,
  $port,
  $driver,
  $dbname                  = $name,
  $ensure                  = 'present',
  $jndiname                = "java:jboss/datasources/${name}",
  $xa                      = hiera('jboss::datasource::xa', true),
  $jta                     = hiera('jboss::datasource::jta', true),
  $profile                 = hiera('jboss::settings::profile', 'full-ha'),
  $controller              = hiera('jboss::settings::controller', 'localhost:9999'),
  $minpoolsize             = hiera('jboss::datasource::minpoolsize', 1),
  $maxpoolsize             = hiera('jboss::datasource::maxpoolsize', 50),
  $validateonmatch         = hiera('jboss::datasource::validateonmatch', false),
  $backgroundvalidation    = hiera('jboss::datasource::backgroundvalidation', false),
  $sharepreparedstatements = hiera('jboss::datasource::sharepreparedstatements', false),
  $enabled                 = hiera('jboss::datasource::enabled', true),
  $runasdomain             = undef,
) {
  include jboss
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
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
  
  jboss_datasource { $name:
    ensure                  => $ensure,
    dbname                  => $dbname,
    enabled                 => $enabled,
    runasdomain             => $realrunasdomain,
    profile                 => $profile,
    controller              => $controller,
    jndiname                => $jndiname,
    jta                     => $jta,
    xa                      => $xa,
    drivername              => $drivername,
    minpoolsize             => $minpoolsize,
    maxpoolsize             => $maxpoolsize,
    username                => $username,
    password                => $password,
    host                    => $host,
    port                    => $port,
    jdbcscheme              => $jdbcscheme,
    validateonmatch         => $validateonmatch,
    backgroundvalidation    => $backgroundvalidation,
    sharepreparedstatements => $sharepreparedstatements,
    notify                  => Exec['jboss::service::restart'],
    require                 => [
      Anchor['jboss::service::end'],
      Jboss_jdbcdriver[$drivername],
    ],
  }
}