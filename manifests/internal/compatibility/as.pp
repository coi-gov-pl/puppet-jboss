# == Class: jboss::internal::compatibility::as
# This is internal class to resolve JBoss AS compatibility
class jboss::internal::compatibility::as {
  include jboss

  if versioncmp($jboss::version, '7.0.0') < 0 or versioncmp($jboss::version, '8.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: JBoss AS 7.x series")
  }
  $systemd_file     = undef
  $systemd_launcher = undef
  $initsystem       = 'SystemV'
  $controller_port  = '9999'
  $product_short    = 'jboss'
  $expect_to_start  = true
  $initd_file       = $jboss::runasdomain ? {
    true    => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
    default => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
  }
}
