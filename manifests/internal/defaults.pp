# == Class: jboss::internal::defaults
#
class jboss::internal::defaults {

  include jboss
  
  # Base URL for downloading Jboss Application Server installation package
  $download_urlbase = hiera('jboss::params::download_urlbase', 'http://download.jboss.org')

  if $jboss::product == 'jboss-as' {
    $as_version = jboss_short_version($jboss::version)
    $trimmed_product_name = regsubst($jboss::product, '-', '')
    $download_url = hiera('jboss::params::download_url', "${download_urlbase}/${trimmed_product_name}/${as_version}/${jboss::product}-${jboss::version}/${jboss::product}-${jboss::version}.zip")
  } else {
    # Full URL for downloading JBoss Application Server installation package
    $download_url     = hiera('jboss::params::download_url', "${download_urlbase}/${jboss::product}/${jboss::version}/${jboss::product}-${jboss::version}.zip")
  }
}
