# Creates JBoss security domain
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
  include jboss::internal::service
  include jboss::internal::runtime::node

  jboss_securitydomain { $name:
    ensure          => $ensure,
    code            => $code,
    codeflag        => $codeflag,
    moduleoptions   => $moduleoptions,
    runasdomain     => $runasdomain,
    profile         => $profile,
    controller      => $controller,
    ctrluser        => $jboss::internal::runtime::node::username,
    ctrlpasswd      => $jboss::internal::runtime::node::password,
    require         => Anchor['jboss::package::end'],
  }

  if str2bool($::jboss_running) {
    Jboss_securitydomain[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_securitydomain[$name] ~> Exec['jboss::service::restart']
  }
}
