class jboss::params {
  $java_install = hiera('jboss::params::java_install', true)
  $java_version = hiera('jboss::params::java_version', "latest")
  $java_package = hiera('jboss::params::java_package', undef)
  $version      = hiera('jboss::params::version', "as-7.1.1.Final")
  $jboss_user   = hiera('jboss::params::jboss_user', "jboss")
  $jboss_group  = hiera('jboss::params::jboss_group', "jboss")
  $download_url = hiera('jboss::params::download_url', "http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip")
  $install_dir  = hiera('jboss::params::install_dir', "/usr/lib")
}
