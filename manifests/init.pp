# == Class: jboss
#
# Installs and manages resources of JBoss EAP and Wildfly application servers.
#
# === Copyright
#
# Copyright 2015 COI
#
class jboss (
  $hostname         = $jboss::params::hostname,
  $jboss_user       = $jboss::params::jboss_user,
  $jboss_group      = $jboss::params::jboss_group,
  $product          = $jboss::params::product,
  $version          = $jboss::params::version,
  $download_url     = "${jboss::params::download_urlbase}/${product}/${version}/${product}-${version}.zip",
  $java_autoinstall = $jboss::params::java_autoinstall,
  $java_version     = $jboss::params::java_version,
  $java_package     = $jboss::params::java_package,
  $install_dir      = $jboss::params::install_dir,
  $runasdomain      = $jboss::params::runasdomain,
  $enableconsole    = $jboss::params::enableconsole,
  $controller       = $jboss::params::controller,
  $profile          = $jboss::params::profile,
  $prerequisites    = Class['jboss::internal::prerequisites'],
  $fetch_tool       = $jboss::params::fetch_tool,
) inherits jboss::params {

  $home = "${install_dir}/${product}-${version}"

  include jboss::internal::configuration
  include jboss::internal::service

  class { 'jboss::internal::package':
    version          => $version,
    product          => $product,
    jboss_user       => $jboss_user,
    jboss_group      => $jboss_group,
    download_url     => $download_url,
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
