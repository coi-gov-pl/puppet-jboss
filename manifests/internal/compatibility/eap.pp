# == Class: jboss::internal::compatibility::eap
# This is internal class to resolve JBoss EAP compatibility
class jboss::internal::compatibility::eap {
  include jboss
  include jboss::internal::compatibility::initsystem

  if versioncmp($jboss::version, '6.0.0') < 0 or versioncmp($jboss::version, '8.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: JBoss EAP 6.x and 7.x series")
  }

  $product_short    = 'jboss'
  $expect_to_start  = true
  $initsystem       = $jboss::internal::compatibility::initsystem::initsystem
  $systemd_file     = 'jboss/systemd/wildfly.service'
  $systemd_launcher = 'jboss/systemd/launch.sh'

  if versioncmp($jboss::version, '7.0.0') >= 0 {
    # after EAP 7.x
    $controller_port  = '9990'
    $initd_file       = "${jboss::home}/bin/init.d/jboss-eap-rhel.sh"
  } else {
    # before EAP 7.x
    $controller_port  = '9999'
    $initd_file       = $jboss::runasdomain ? {
      true    => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
      default => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
    }
  }
}
