# Creates JBoss datasources, standard and xa
define jboss::datasource (
  $username,
  $password,
  $jdbcscheme,
  $host,
  $port,
  $driver,
  $dbname                      = $name,
  $ensure                      = 'present',
  $jndiname                    = "java:jboss/datasources/${name}",
  $xa                          = hiera('jboss::datasource::xa', true),
  $jta                         = hiera('jboss::datasource::jta', true),
  $profile                     = $::jboss::profile,
  $controller                  = $::jboss::controller,
  $minpoolsize                 = hiera('jboss::datasource::minpoolsize', 1),
  $maxpoolsize                 = hiera('jboss::datasource::maxpoolsize', 50),
  $enabled                     = hiera('jboss::datasource::enabled', true),
  $options                     = {},
  $runasdomain                 = $::jboss::runasdomain,
) {
  include jboss::internal::service
  include jboss::internal::runtime::node

  $drivername = $driver['name']

  $default_hash = {
    'validate-on-match'              => hiera('jboss::datasource::validateonmatch', false),
    'background-validation'          => hiera('jboss::datasource::backgroundvalidation', false),
    'share-prepared-statements'      => hiera('jboss::datasource::sharepreparedstatements', false),
    'prepared-statements-cache-size' => hiera('jboss::datasource::preparedstatementscachesize', 0)
  }

  if $xa {
    $default_xa_hash = {
      'same-rm-override' => hiera('jboss::datasource::samermoverride', true),
      'wrap-xa-resource' => hiera('jboss::datasource::wrapxaresource', true)
    }
    $default_options = merge($default_hash, $default_xa_hash)
  } else {
    $default_options = $default_hash
  }

  $actual_options = merge($default_options, $options)

  if ! defined(Jboss_jdbcdriver[$drivername]) and $ensure == 'present' {

    $datasourceclassname = has_key($driver, 'datasourceclassname') ? {
      true    => $driver['datasourceclassname'],
      default => undef,
    }

    $xadatasourceclassname = has_key($driver, 'xadatasourceclassname') ? {
      true    => $driver['xadatasourceclassname'],
      default => undef,
    }

    jboss_jdbcdriver { $drivername:
      ensure                => 'present',
      classname             => $driver['classname'],
      modulename            => $driver['modulename'],
      datasourceclassname   => $datasourceclassname,
      xadatasourceclassname => $xadatasourceclassname,
      runasdomain           => $runasdomain,
      profile               => $profile,
      controller            => $controller,
      ctrluser              => $jboss::internal::runtime::node::username,
      ctrlpasswd            => $jboss::internal::runtime::node::password,
      require               => Anchor['jboss::package::end'],
    }
    if str2bool($::jboss_running) {
      Jboss_jdbcdriver[$drivername] ~> Service[$jboss::internal::service::servicename]
    } else {
      Anchor['jboss::service::end'] -> Jboss_jdbcdriver[$drivername] ~> Exec['jboss::service::restart']
    }
  }

  jboss_datasource { $name:
    ensure                      => $ensure,
    dbname                      => $dbname,
    enabled                     => $enabled,
    runasdomain                 => $runasdomain,
    profile                     => $profile,
    controller                  => $controller,
    ctrluser                    => $jboss::internal::runtime::node::username,
    ctrlpasswd                  => $jboss::internal::runtime::node::password,
    jndiname                    => $jndiname,
    jta                         => $jta,
    xa                          => $xa,
    drivername                  => $drivername,
    minpoolsize                 => $minpoolsize,
    maxpoolsize                 => $maxpoolsize,
    username                    => $username,
    password                    => $password,
    host                        => $host,
    port                        => $port,
    jdbcscheme                  => $jdbcscheme,
    options                     => $actual_options,
    require                     => [
      Anchor['jboss::package::end'],
      Jboss_jdbcdriver[$drivername],
    ],
  }

  if str2bool($::jboss_running) {
    Jboss_datasource[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_datasource[$name] ~> Exec['jboss::service::restart']
  }
}
