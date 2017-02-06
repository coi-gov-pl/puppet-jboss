# == Class: jboss
#
# The `jboss` main class is used to install the application server itself. It can install it on default parameters but you can use
# then to customize installation procedure.
#
# === Standard metaparameters
#
# [*runasdomain*]
#     This parameter is used to configure JBoss server to run in domain or standalone mode. By default is equal to `false`, so
#     JBoss runs in standalone mode. Set it to `true` to setup domain mode.
# [*profile*]
#     JBoss profile to use. By default it is equal to `full`, which is the default profile in JBoss server. You can use any other
#     default profile to start with: `full`, `ha`, `full-ha`.
# [*controller*]
#     To with controller connect to. By default it is equals to `127.0.0.1:9999` on jboss servers and `127.0.0.1:9990` on wildfly
#     server.
#
# === Parameters
#
# [*hostname*]
#     It is used to name jboss main `host.xml` key to distinguish from other hosts in distributed environment. By default is
#     equals to `$::hostname` fact. Applicable Hiera key: `jboss::params::hostname`
# [*product*]
#     Name of the JBoss product. Can be one of: `jboss-eap`, `jboss-as` or `wildfly`. By default this is equals to `wildfly`.
#     Applicable Hiera key: `jboss::params::product`
# [*jboss_user*]
#     The name of the user to be used as owner of JBoss files in filesystem. It will be also used to run JBoss processes. Be default
#     it is equal to `jboss` for `jboss-eap` and `jboss-as` server and `wildfly` for `wildfly` server. Applicable Hiera key:
#     `jboss::params::jboss_user`
# [*jboss_group*]
#     The filesystem group to be used as a owner of JBoss files. By default it is equal to the same value as `$jboss::jboss_user`.
# [*download_url*]
#     The download URL from which JBoss zip file will be downloaded. Be default it is equal to
#     `http://download.jboss.org/<product>/<version>/<product>-<version>.zip`
# [*java_autoinstall*]
#     This parameter is by default equal to `true` and if so it will install default Java JDK using `puppetlabs/java`. Applicable
#     Hiera key: `jboss::params::java_autoinstall`
# [*java_version*]
#     This parameter is by default equals to `latest` and it is passed to `puppetlabs/java` module. You can give other values. For
#     details look in Puppetlabs/Java module dodumentation. Applicable Hiera key: `jboss::params::java_version`
# [*java_package*]
#     The name of Java JDK package to use. Be default it is used to `undef` and it is passed to `puppetlabs/java`. Possible values
#     are: `jdk`, `jre`. For details look in Puppetlabs/Java module dodumentation. Applicable Hiera key:
#     `jboss::params::java_package`
# [*install_dir*]
#     The directory to use as installation home for JBoss Application Server. By default it is equal to
#     `/usr/lib/<product>-<version>`. Applicable Hiera key: `jboss::params::install_dir`
# [*controller_host*]
#     To with controller connect to. By default it is equals to `127.0.0.1`.
# [*enableconsole*]
#     This parameter is used to enable or disable access to JBoss management web console. It is equal to `false` by default, so the
#     console is turned off. Applicable Hiera key: `jboss::params::enableconsole`
# [*prerequisites*]
#     The class to use as a JBoss prerequisites which will be processed before installation. By default is equal to
#     `Class['jboss::internal::prerequisites']`. The default class is used to install `wget` package. If you would like to install
#     `wget` in diffrent way, please write your class that does that and pass reference to it as this parameter
# [*fetch_tool*]
#     This parameter is by default equal to `jboss::internal::util::download`. This is a default implementation for fetching files
#     (mostly JBoss zip files) with `wget`. If you would like to use your own implementation, please write your custom define with
#     the same interface as `jboss::internal::util::download` and pass it's name to this parameter. Applicable Hiera key:
#     `jboss::params::fetch_tool`
#
# === Copyright
#
# Copyright (R) 2015 COI
#
class jboss (
  $hostname         = $jboss::params::hostname,
  $product          = $jboss::params::product,
  $jboss_user       = $jboss::params::jboss_user,
  $jboss_group      = $jboss::params::jboss_group,
  $version          = $jboss::params::version,
  $download_url     = undef,
  $java_autoinstall = $jboss::params::java_autoinstall,
  $java_version     = $jboss::params::java_version,
  $java_package     = $jboss::params::java_package,
  $install_dir      = $jboss::params::install_dir,
  $runasdomain      = $jboss::params::runasdomain,
  $controller_host  = $jboss::params::controller_host,
  $enableconsole    = $jboss::params::enableconsole,
  $profile          = $jboss::params::profile,
  $prerequisites    = Class['jboss::internal::prerequisites'],
  $fetch_tool       = $jboss::params::fetch_tool,
) inherits jboss::params {

  $home              = "${install_dir}/${product}-${version}"

  include jboss::internal::defaults
  include jboss::internal::runtime

  include jboss::internal::compatibility

  $controller       = "${controller_host}:${jboss::internal::compatibility::controller_port}"

  include jboss::internal::configuration
  include jboss::internal::service

  $servicename = $jboss::internal::service::servicename

  $full_download_url = $jboss::internal::runtime::download_url

  if $full_download_url == undef {
    fail Puppet::Error, 'Full download url cannot be undef'
  }

  class { 'jboss::internal::package':
    version          => $version,
    product          => $product,
    jboss_user       => $jboss_user,
    jboss_group      => $jboss_group,
    download_url     => $full_download_url,
    java_autoinstall => $java_autoinstall,
    java_version     => $java_version,
    java_package     => $java_package,
    install_dir      => $install_dir,
    prerequisites    => $prerequisites,
    require          => Anchor['jboss::begin'],
  }
  include jboss::internal::package

  anchor { 'jboss::begin': }

  anchor { 'jboss::end':
    require => [
      Class['jboss::internal::package'],
      Class['jboss::internal::configuration'],
      Class['jboss::internal::service'],
      Anchor['jboss::begin'],
      Anchor['jboss::package::end'],
      Anchor['jboss::service::end'],
    ],
  }
}
