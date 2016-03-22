# JBoss internals - class that calculates and hold variables calculated at runtime
class jboss::internal::runtime {
  include jboss

  # Base URL for downloading Jboss Application Server installation package
  $download_urlbase = hiera('jboss::params::download_urlbase', 'http://download.jboss.org')

  # Full URL for downloading JBoss Application Server installation package
  $download_url     = hiera('jboss::params::download_url', "${download_urlbase}/${jboss::product}/${jboss::version}/${jboss::product}-${jboss::version}.zip")

  $runasdomain   = $jboss::runasdomain
  $profile       = $jboss::profile

  $domainconfigfile = 'domain.xml'
  $hostconfigfile = 'host.xml'

  $standaloneconfigfile = $profile ? {
    ''        => 'standalone.xml',
    'ha'      => 'standalone-ha.xml',
    'osgi'    => 'standalone-osgi.xml',
    'full'    => 'standalone-full.xml',
    'full-ha' => 'standalone-full-ha.xml',
    default   => 'standalone-full.xml'
  }

  $configfile = $runasdomain ? {
    true    => $domainconfigfile,
    default => $standaloneconfigfile,
  }

  validate_absolute_path($jboss::home)

  $standaloneconfigpath = "${jboss::home}/standalone/configuration/${standaloneconfigfile}"
  $hostconfigpath = "${jboss::home}/domain/configuration/${hostconfigfile}"
  $domainconfigpath = "${jboss::home}/domain/configuration/${domainconfigfile}"

  include jboss::internal::runtime::dc
}
