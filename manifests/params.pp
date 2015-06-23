# JBoss parameters
class jboss::params inherits jboss::internal::params {

  # JBoss product name
  $product          = hiera('jboss::params::product', 'wildfly')

  # Version of JBoss Application Server
  $version          = hiera('jboss::params::version', '8.2.0.Final')

  # Should java be installed by this module automatically?
  $java_autoinstall = hiera('jboss::params::java_install', true)

  # The version of Java to be installed, default: latest
  $java_version     = hiera('jboss::params::java_version', 'latest')

  # Java package version, undef, jdk, jre
  $java_package     = hiera('jboss::params::java_package', undef)

  # User for Jboss Application Server
  $jboss_user       = hiera('jboss::params::jboss_user', 'jboss')

  # Group for Jboss Application Server
  $jboss_group      = hiera('jboss::params::jboss_group', 'jboss')

  # Download URL for Jboss Application Server installation package
  $download_urlbase = hiera('jboss::params::download_urlbase', 'http://download.jboss.org')

  # Target installation directory root
  $install_dir      = hiera('jboss::params::install_dir', '/usr/lib')

  # Runs JBoss Application Server in domain mode
  $runasdomain      = hiera('jboss::params::runasdomain', false)

  # Enable JBoss Application Server management console
  $enableconsole    = hiera('jboss::params::enableconsole', false)

  # JBoss default domain profile
  $profile          = hiera('jboss::settings::profile', 'full')

  #JBoss default domain controller
  $controller       = hiera('jboss::settings::controller','localhost:9999')

  # JBoss bind public interface to:
  $bind_public      = hiera('jboss::params::bind_public', undef)

  # JBoss bind management interface to:
  $bind_mgmt        = hiera('jboss::params::bind_mgmt', undef)

  # JBoss default host name
  $hostname         = hiera('jboss::params::hostname', $::hostname)

  # Tool used by this module to fetch JBoss installation files from network
  $fetch_tool       = hiera('jboss::params::fetch_tool', 'jboss::internal::util::download')

  include jboss::params::mod_cluster

}
