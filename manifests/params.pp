# @summary JBoss parameters
class jboss::params inherits jboss::internal::params {

  # @param JBoss product name
  $product          = hiera('jboss::params::product', 'wildfly')

  # @param Version of JBoss Application Server
  $version          = hiera('jboss::params::version', '9.0.2.Final')

  # Deprcated, will deleted in next major version
  include jboss::internal::quirks::autoinstall

  # @param Should java be installed by this module automatically?,
  #   Default value is set to true
  $java_autoinstall = jboss_to_bool(hiera('jboss::params::java_autoinstall',
  $jboss::internal::quirks::autoinstall::deprecated_java_install))

  # @param The version of Java to be installed, default: latest
  $java_version     = hiera('jboss::params::java_version', 'latest')

  # @param Java package version, undef, jdk, jre
  $java_package     = hiera('jboss::params::java_package', undef)

  # @param Java distribution: jre or jdk
  $java_dist        = hiera('jboss::params::java_dist', 'jre')

  # @param Environment variables passed as Hash (key-value). Those variables are set to
  #   main java process. Keep in mind that in standalone mode that's actual server,
  #   but in domain mode that's host controller!
  #
  # @example Setting additional JAVA_OPTS while reusing default options set by JBoss
  #   $environment = {
  #     'JAVA_OPTS' => "\${JAVA_OPTS} -Xmx4g -XX:+UseG1GC",
  #   }
  $environment      = hiera('jboss::params::environment', {})

  # @param User for Jboss Application Server
  $jboss_user       = hiera('jboss::params::jboss_user', 'jboss')

  # @param Group for Jboss Application Server
  $jboss_group      = hiera('jboss::params::jboss_group', 'jboss')

  # @param Target installation directory root
  $install_dir      = hiera('jboss::params::install_dir', '/usr/lib')

  # @param Runs JBoss Application Server in domain mode
  $runasdomain      = jboss_to_bool(hiera('jboss::params::runasdomain', false))

  # @param Enable JBoss Application Server management console
  $enableconsole    = jboss_to_bool(hiera('jboss::params::enableconsole', false))

  # @param JBoss default domain profile
  $profile          = hiera('jboss::settings::profile', 'full')

  # @param JBoss default domain controller's hostname
  $controller_host  = hiera('jboss::settings::controller', '127.0.0.1')

  # @param JBoss bind public interface to:
  $bind_public      = hiera('jboss::params::bind_public', undef)

  # @param JBoss bind management interface to:
  $bind_mgmt        = hiera('jboss::params::bind_mgmt', undef)

  # @param JBoss default host name
  $hostname         = hiera('jboss::params::hostname', $::hostname)

  # @param Tool used by this module to fetch JBoss installation files from network
  $fetch_tool       = hiera('jboss::params::fetch_tool', 'jboss::internal::util::download')

  # @param Time to wait (in seconds) for server to become available
  $startup_wait     = jboss_to_i(jboss_to_s(hiera('jboss::params::startup_wait', 60)))

}
