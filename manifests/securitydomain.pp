include jboss::params
/**
 * Creates JBoss security domain
 */
define jboss::securitydomain (
  $code                    = undef,
  $codeflag                = undef,
  $moduleoptions           = undef,
  $ensure                  = 'present',
  $profile                 = $jboss::params::profile,
  $controller              = $jboss::params::controller,
  $runasdomain             = undef,
) {
  include jboss
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
  
  jboss_securitydomain { $name:
    code                    => $code,
    codeflag                => $codeflag,
    moduleoptions           => $moduleoptions,
    ensure                  => $ensure,
    runasdomain             => $realrunasdomain,
    profile                 => $profile,
    controller              => $controller,
    notify                  => Exec['jboss::service::restart'],
    require                 => [
      Anchor['jboss::service::end'],
    ],
  }
}