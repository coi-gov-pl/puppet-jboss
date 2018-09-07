# @summary Installs JBoss EAP and WildFly application servers and manage their
#   resources and applications in either a domain or a stand-alone mode
#
# The `jboss` main class is used to install the application server itself. It can
#   install it on default parameters but you can use then to customize installation
#    procedure.
#
# @example Basic usage
#   include jboss
#
# @param product
#   Name of the JBoss product. Can be one of: `'jboss-eap'`, `'jboss-as'` or `'wildfly'`.
#   By default this is equals to `'wildfly'`.
# @param version
#   Version of application server to install. Default value is `'9.0.2.Final'`.
# @param runasdomain
#   This parameter is used to configure JBoss server to run in domain or standalone mode.
#   By default is equal to `false`, so JBoss runs in standalone mode. Set it to `true`
#   to setup domain mode.
# @param profile
#   JBoss profile to use. By default it is equal to `'full'`, which is the default profile
#   in JBoss server. You can use any other default profile to start with:
#   `'full'`, `'ha'`, `'full-ha'`.
# @param enableconsole
#   This parameter is used to enable or disable access to JBoss management web console.
#   It is equal to `false` by default, so the console is turned off.
# @param java_autoinstall
#   This parameter is by default set to `true`, and if so, it will install default Java
#   JDK using `puppetlabs/java` module.
# @param java_version
#   This parameter is, by default, set to `'latest'`, and it is passed to `puppetlabs/java`
#   module. You can give other values. For more details refer to `puppetlabs/java` module
#   dodumentation.
# @param java_package
#   The name of Java JDK package to use. Be default, it is set to `undef`, and it is passed
#   directly to `puppetlabs/java` module. Possible values are: `jdk`, `jre`. For details
#   please refer to `puppetlabs/java` module dodumentation.
# @param environment
#   Environmental variables (for ex.: JAVA_OPTS) that will be passed to JBoss main java process.
#   This value must be provided as Puppet's Hash, that key - value array.
#
#   Please, note that in domain mode you propably would like to configure variables on server
#   group or specific virtual server instead. That's because this parameter in domain mode will
#   effectivly configure environmental variables for domain host controller, not actual server
#   that runs applications.
#
#   If you configure environmental variables, please note that they will override default values
#   provided by Red Hat. So to preserve orginal values use shell variable syntax.
#
#   Example:
#   `environment => { 'JAVA_OPTS' => "\${JAVA_OPTS} -Xmx4g -XX:+UseG1GC", }`
# @param install_dir
#   The directory to use as installation home for JBoss or Wildfly server. By default it is set
#   to `/usr/lib/<product>-<version>`.
# @param hostname
#   It is used to name jboss main `host.xml` key to distinguish from other hosts in distributed
#   environment. By default isset to `$::hostname` fact.
# @param jboss_user
#   The name of the user to be used as owner of JBoss files in filesystem. It will be also used
#   to run JBoss processes. Be default it is set to `'jboss'` for `jboss-eap` and `jboss-as` servers,
#   and `'wildfly'` for `wildfly` server.
# @param jboss_group
#   The filesystem group to be used as a owner of JBoss files. By default it is equal to the same
#   value as `$jboss::jboss_user`.
# @param download_url
#   The download URL from which JBoss zip file will be downloaded. By default it is set
#   to: `http://download.jboss.org/${product}/${version}/${product}-${version}.zip`
# @param controller_host
#   To which controller connect to. By default it is equals to `'127.0.0.1'`.
# @param prerequisites
#   The class to use as a JBoss prerequisites which will be processed before installation. By
#   default is equal to `Class['jboss::internal::prerequisites']`. The default class is used
#   to install `wget` package. If you would like to install `wget` in diffrent way, please
#   write your class that does that and pass reference to it as this parameter.
# @param fetch_tool
#   This parameter is by default set to `jboss::internal::util::download`. This is a default
#   implementation for fetching files (mostly JBoss zip files) with `wget`. If you would like
#   to use your own implementation, please write your custom define with the same parameters
#   as `jboss::internal::util::download` and pass it's name to this parameter.
#
# Copyright (R) 2015-2018 COI
#
class jboss (
  $product          = $jboss::params::product,
  $version          = $jboss::params::version,
  $runasdomain      = $jboss::params::runasdomain,
  $profile          = $jboss::params::profile,
  $enableconsole    = $jboss::params::enableconsole,
  $java_autoinstall = $jboss::params::java_autoinstall,
  $java_version     = $jboss::params::java_version,
  $java_package     = $jboss::params::java_package,
  $environment      = $jboss::params::environment,
  $install_dir      = $jboss::params::install_dir,
  $hostname         = $jboss::params::hostname,
  $jboss_user       = $jboss::params::jboss_user,
  $jboss_group      = $jboss::params::jboss_group,
  $download_url     = undef,
  $controller_host  = $jboss::params::controller_host,
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
