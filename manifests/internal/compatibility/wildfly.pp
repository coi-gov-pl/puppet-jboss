# == Class: jboss::internal::compatibility::wildfly
# This is internal class to resolve Wildfly compatibility
class jboss::internal::compatibility::wildfly {
  include jboss
  include jboss::internal::compatibility::common
  $_osfamily_down = $jboss::internal::compatibility::common::osfamily_down

  if versioncmp($jboss::version, '8.0.0') < 0 or versioncmp($jboss::version, '11.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: Wildfly 8.x, 9.x and 10.x series")
  }
  $systemd_file     = 'jboss/systemd/wildfly.service'
  $systemd_launcher = 'jboss/systemd/launch.sh'
  $controller_port  = '9990'
  $product_short    = 'wildfly'

  if versioncmp($jboss::version, '10.0.0') >= 0 {
    # after WFly 10.x
    $initd_file = "${jboss::home}/docs/contrib/scripts/init.d/wildfly-init-${_osfamily_down}.sh"
  } else {
    # for WFly 8.x, 9.x
    $initd_file = "${jboss::home}/bin/init.d/wildfly-init-${_osfamily_down}.sh"
  }
}
