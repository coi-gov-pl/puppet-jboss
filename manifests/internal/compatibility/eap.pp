# == Class: jboss::internal::compatibility::eap
# This is internal class to resolve JBoss EAP compatibility
class jboss::internal::compatibility::eap {
  include jboss

  if versioncmp($jboss::version, '6.0.0') < 0 or versioncmp($jboss::version, '8.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: JBoss EAP 6.x and 7.x series")
  }

  $systemd_file     = undef
  $systemd_launcher = undef
  $initsystem       = 'SystemV'

  $_eap_after7x = ( versioncmp($jboss::version, '7.0.0') >= 0 )
  if $_eap_after7x and $::osfamily != 'RedHat' {
    fail("Jboss EAP 7.x is supported only on RHEL systems, but tried on ${::osfamily}!")
  }
  $initsystem    = 'SystemV'
  $product_short = 'jboss'
  if $_eap_after7x {
    # after EAP 7.x
    $controller_port = '9990'
    $initd_file      = "${jboss::home}/bin/init.d/jboss-eap-rhel.sh"
  } else {
    # before EAP 7.x
    $controller_port = '9999'
    $initd_file      = $jboss::runasdomain ? {
      true    => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
      default => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
    }
  }
}
