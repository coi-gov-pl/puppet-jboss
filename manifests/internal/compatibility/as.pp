# == Class: jboss::internal::compatibility::as
# This is internal class to resolve JBoss AS compatibility
class jboss::internal::compatibility::as {
  include jboss
  include jboss::internal::compatibility::initsystem

  if versioncmp($jboss::version, '7.0.0') < 0 or versioncmp($jboss::version, '8.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: JBoss AS 7.x series")
  }

  $initsystem       = $jboss::internal::compatibility::initsystem::initsystem
  $controller_port  = '9999'
  $product_short    = 'jboss'
  $systemd_file     = 'jboss/systemd/wildfly.service'
  $systemd_launcher = 'jboss/systemd/launch.sh'
  $initd_file       = $jboss::runasdomain ? {
    true    => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
    default => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
  }
}
