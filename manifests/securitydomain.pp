/**
 * Creates JBoss security domain
 */
define jboss::securitydomain (
  $code                    = undef,
  $codeflag                = undef,
  $moduleoptions           = undef,
  $ensure                  = 'present',
  $profile                 = $::jboss::profile,
  $controller              = $::jboss::controller,
  $runasdomain             = $::jboss::runasdomain,
) {
  include jboss
  
  jboss_securitydomain { $name:
    code                    => $code,
    codeflag                => $codeflag,
    moduleoptions           => $moduleoptions,
    ensure                  => $ensure,
    runasdomain             => $runasdomain,
    profile                 => $profile,
    controller              => $controller,
    notify                  => Exec['jboss::service::restart'],
    require                 => [
      Anchor['jboss::service::end'],
    ],
  }
}