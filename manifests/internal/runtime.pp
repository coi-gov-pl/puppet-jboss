# JBoss internals - class that calculates and hold variables calculated at runtime
class jboss::internal::runtime {
  include jboss

  $runasdomain   = $jboss::runasdomain
  $profile       = $jboss::profile

  $domainbinconfigfile     = 'domain.conf'
  $standalonebinconfigfile = 'standalone.conf'

  $domainconfigfile = 'domain.xml'
  $hostconfigfile   = 'host.xml'

  $standaloneconfigfile = $profile ? {
    ''        => 'standalone.xml',
    'ha'      => 'standalone-ha.xml',
    'osgi'    => 'standalone-osgi.xml',
    'full'    => 'standalone-full.xml',
    'full-ha' => 'standalone-full-ha.xml',
    default   => 'standalone-full.xml'
  }

  $binconfigfile = $runasdomain ? {
    true    => $domainbinconfigfile,
    default => $standalonebinconfigfile,
  }

  $configfile = $runasdomain ? {
    true    => $domainconfigfile,
    default => $standaloneconfigfile,
  }

  validate_absolute_path($jboss::home)

  $standaloneconfigpath = "${jboss::home}/standalone/configuration/${standaloneconfigfile}"
  $hostconfigpath       = "${jboss::home}/domain/configuration/${hostconfigfile}"
  $domainconfigpath     = "${jboss::home}/domain/configuration/${domainconfigfile}"

  $binconfigpath        = "${jboss::home}/bin/${binconfigfile}"

  include jboss::internal::runtime::dc
}
