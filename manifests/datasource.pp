# == Define: jboss::datasource
#
# This defined type can be used to add and remove JBoss data sources. It support both XA and Non-XA data sources. It can setup data
# sources and manage required drivers.
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*jdbcscheme*]
#     **Required parameter.** This is the JDBC scheme for ex.: `postgresql`, `oracle`, `mysql`, `mssql` or `h2:mem`. All accepted
#     by JBoss JDBC shemes are valid.
# [*host*]
#     **Required parameter.** This is the name of the database host or it's IP address. Pass empty string `''` if host isn't needed.
# [*port*]
#     **Required parameter.** This is the port of the database. Pass empty string `''` if port isn't needed.
# [*username*]
#     **Required parameter.** This is the user name that will be used to connect to database.
# [*password*]
#     **Required parameter.** This is the password that will be used to connect to database.
# [*dbname*]
#     **This is the namevar**. Name of the database to be used.
# [*ensure*]
#     Standard ensure parameter. Can be either `present` or `absent`.
# [*jndiname*]
#     Java JNDI name of the datasource. Be default it is equals to `java:jboss/datasources/<name>`
# [*xa*]
#     This parameters indicate that given data source should XA or Non-XA type. Be default this is equal to `false`
# [*jta*]
#     This parameters indicate that given data source should support Java JTA transactions. Be default this is equal to `true`
# [*minpoolsize*]
#     Minimum connections in connection pool. By default it is equal to `1`.
# [*maxpoolsize*]
#     Maximum connections in connection pool. By default it is equal to `50`.
# [*enabled*]
#     This parameter control whether given data source should be enabled or not. By default it is equal to `true`.
# [*options*]
#     This is an extra options hash. You can give any additional options that will be passed directly to JBoss data source. Any
#     supported by JBoss values will be accepted and enforced. Values that are not mentioned are not processed.
#
#     Default options added to every data source (they can be overwritten):
#
#      - `validate-on-match` => `false`
#      - `background-validation` => `false`
#      - `share-prepared-statements` => `false`
#      - `prepared-statements-cache-size` => `0`
#
#     Default options added to every XA data source (they can be overwritten):
#
#      - `same-rm-override` => `true`
#      - `wrap-xa-resource` => `true`
#
define jboss::datasource (
  $jdbcscheme,
  $host,
  $port,
  $username,
  $password,
  $driver,
  $dbname                      = $name,
  $ensure                      = 'present',
  $jndiname                    = "java:jboss/datasources/${name}",
  $xa                          = jboss_to_bool(hiera('jboss::datasource::xa', false)),
  $jta                         = jboss_to_bool(hiera('jboss::datasource::jta', true)),
  $profile                     = $::jboss::profile,
  $controller                  = $::jboss::controller,
  $minpoolsize                 = jboss_to_i(hiera('jboss::datasource::minpoolsize', 1)),
  $maxpoolsize                 = jboss_to_i(hiera('jboss::datasource::maxpoolsize', 50)),
  $enabled                     = jboss_to_bool(hiera('jboss::datasource::enabled', true)),
  $options                     = {},
  $runasdomain                 = $::jboss::runasdomain,
) {
  include jboss
  include jboss::internal::service
  include jboss::internal::runtime::node

  $drivername = $driver['name']

  $default_hash = {
    'validate-on-match'              => jboss_to_bool(hiera('jboss::datasource::validateonmatch', false)),
    'background-validation'          => jboss_to_bool(hiera('jboss::datasource::backgroundvalidation', false)),
    'share-prepared-statements'      => jboss_to_bool(hiera('jboss::datasource::sharepreparedstatements', false)),
    'prepared-statements-cache-size' => jboss_to_i(hiera('jboss::datasource::preparedstatementscachesize', 0))
  }

  if $xa {
    $default_xa_hash = {
      'same-rm-override' => jboss_to_bool(hiera('jboss::datasource::samermoverride', true)),
      'wrap-xa-resource' => jboss_to_bool(hiera('jboss::datasource::wrapxaresource', true))
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
      before                => Jboss_Datasource[$name],
    }
    if jboss_to_bool($::jboss_running) {
      Jboss_jdbcdriver[$drivername] ~> Service[$jboss::internal::service::servicename]
    } else {
      Anchor['jboss::service::end'] -> Jboss_jdbcdriver[$drivername] ~> Exec['jboss::service::restart']
    }
  }

  jboss_datasource { $name:
    ensure      => $ensure,
    dbname      => $dbname,
    enabled     => $enabled,
    runasdomain => $runasdomain,
    profile     => $profile,
    controller  => $controller,
    ctrluser    => $jboss::internal::runtime::node::username,
    ctrlpasswd  => $jboss::internal::runtime::node::password,
    jndiname    => $jndiname,
    jta         => $jta,
    xa          => $xa,
    drivername  => $drivername,
    minpoolsize => $minpoolsize,
    maxpoolsize => $maxpoolsize,
    username    => $username,
    password    => $password,
    host        => $host,
    port        => $port,
    jdbcscheme  => $jdbcscheme,
    options     => $actual_options,
    require     => [
      Anchor['jboss::package::end'],
    ],
  }

  if jboss_to_bool($::jboss_running) {
    Jboss_datasource[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_datasource[$name] ~> Exec['jboss::service::restart']
  }
}
