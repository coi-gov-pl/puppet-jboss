define jboss::securitydomain (
  $code                    = undef,
  $codeflag                = undef,
  $moduleoptions           = undef,
  $ensure                  = 'present',
  $profile                 = hiera('jboss::datasource::profile', 'full-ha'),
  $controller              = hiera('jboss::datasource::controller', 'localhost:9999'),
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