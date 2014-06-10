class jboss::params inherits jboss::internal::params {
  # Version of JBoss Application Server
  $version          = hiera('jboss::params::version', "as-7.1.1.Final")
  
  # Short version number
  $version_short    = hiera('jboss::params::version_short', '7.1')
  
  # Should java be installed by this module automatically? 
  $java_autoinstall = hiera('jboss::params::java_install', true)
  
  # The version of Java to be installed, default: latest
  $java_version     = hiera('jboss::params::java_version', "latest")
  
  # Java package version, undef, jdk, jre
  $java_package     = hiera('jboss::params::java_package', undef)
  
  # User for Jboss Application Server 
  $jboss_user       = hiera('jboss::params::jboss_user', "jboss")
  
  # Group for Jboss Application Server
  $jboss_group      = hiera('jboss::params::jboss_group', "jboss")
  
  # Download URL for Jboss Application Server installation package
  $download_url     = hiera('jboss::params::download_url', "http://download.jboss.org/jbossas/${version_short}/jboss-${version}/jboss-${version}.zip")
  
  # Target installation directory root
  $install_dir      = hiera('jboss::params::install_dir', "/usr/lib")
  
  # Runs JBoss Application Server in domain mode
  $runasdomain      = hiera('jboss::params::runasdomain', false)
  
  # Enable JBoss Application Server management console
  $enableconsole    = hiera('jboss::params::enableconsole', false)
  
  # JBoss default domain profile
  $profile      = hiera('jboss::settings::profile', 'full')
  
  #JBoss default domain controller
  $controller   = hiera('jboss::settings::controller','localhost:9999')
  
  class mod_cluster {
    # Version of mod_cluster
    $version = hiera('jboss::params::mod_cluster::version', "1.2.6.Final")
  }
  
}
