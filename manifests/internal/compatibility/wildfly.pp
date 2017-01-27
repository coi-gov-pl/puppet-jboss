# == Class: jboss::internal::compatibility::wildfly
# This is internal class to resolve Wildfly compatibility
class jboss::internal::compatibility::wildfly {
  include jboss
  include jboss::internal::compatibility::common
  include jboss::internal::compatibility::initsystem
  $_osfamily_down = $jboss::internal::compatibility::common::osfamily_down

  if versioncmp($jboss::version, '8.0.0') < 0 or versioncmp($jboss::version, '11.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: Wildfly 8.x, 9.x and 10.x series")
  }
  $systemd_file     = 'jboss/systemd/wildfly.service'
  $systemd_launcher = 'jboss/systemd/launch.sh'
  $initsystem       = $jboss::internal::compatibility::initsystem::initsystem
  $controller_port  = '9990'
  $product_short    = 'wildfly'
  $versioned_name   = "${::operatingsystem} ${::operatingsystemrelease}"
  $not_start_warn1  = 'Wildfly >= 10 requires Java 8 or greater to operate. Module puppetlabs/java will install older version of Java on'
  $not_start_warn2  = " ${versioned_name}. Install Java 8 and set flag \$jboss::java_autoinstall to false to suppress this warning."
  $not_start_warn   = "${not_start_warn1}${not_start_warn2}"

  if jboss_to_bool($jboss::java_autoinstall) and $initsystem == 'SystemV' {
    warning($not_start_warn)
    $expect_to_start = false
  } else {
    $expect_to_start = true
  }

  if versioncmp($jboss::version, '10.0.0') >= 0 {
    # after WFly 10.x
    $initd_file = "${jboss::home}/docs/contrib/scripts/init.d/wildfly-init-${_osfamily_down}.sh"
  } else {
    # for WFly 8.x, 9.x
    $initd_file = "${jboss::home}/bin/init.d/wildfly-init-${_osfamily_down}.sh"
  }
}
