define jboss::securitydomain (
  $code                    = undef,
  $codeflag                = undef,
  $moduleoptions           = undef,
  $ensure                  = 'present',
  $profile                 = hiera('jboss::datasource::profile', 'default'),
  $controller              = hiera('jboss::datasource::controller', 'localhost:9999'),
  $runasdomain             = undef,
) {
  include jboss
  
  $realrunasdomain = $runasdomain ? {
    undef   => $jboss::runasdomain,
    default => $runasdomain,
  }
  securitydomain { $name:
    code                    => $code,
    codeflag                => $codeflag,
    moduleoptions           => $moduleoptions,
    ensure                  => $ensure,
    runasdomain             => $realrunasdomain,
    profile                 => $profile,
    controller              => $controller,
    require                 => [
      Anchor['jboss::service::end'],
    ],
  }
}