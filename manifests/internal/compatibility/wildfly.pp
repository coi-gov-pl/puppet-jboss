# == Class: jboss::internal::compatibility::wildfly
# This is internal class to resolve Wildfly compatibility
class jboss::internal::compatibility::wildfly {
  include jboss
  include jboss::internal::compatibility::common
  $_osfamily_down = $jboss::internal::compatibility::common::osfamily_down

  if versioncmp($jboss::version, '8.0.0') < 0 or versioncmp($jboss::version, '11.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: Wildfly 8.x, 9.x and 10.x series")
  }
  $controller_port = '9990'
  $product_short   = 'wildfly'

  if versioncmp($jboss::version, '10.0.0') >= 0 {
    # after WFly 10.x
    $initd_file       = "${jboss::home}/docs/contrib/scripts/init.d/wildfly-init-${_osfamily_down}.sh"
    $systemd_file     = 'jboss/systemd/wildfly.service'
    $systemd_launcher = 'jboss/systemd/launch.sh'
    case $::osfamily {
      'RedHat': {
        case $::operatingsystem {
          'RedHat', 'CentOS', 'OracleLinux', 'Scientific', 'OEL': {
            if (versioncmp($::operatingsystemrelease, '7.0') > 0) {
              $initsystem = 'SystemD'
            } else {
              $initsystem = 'SystemV'
              $versioned_name = "${::operatingsystem} ${::operatingsystemrelease}"
              if jboss_to_bool($jboss::java_autoinstall) {
                warning("Wildfly 10 requires Java 8 or greater, which is not suppoted by default on ${versioned_name}.")
              }
            }
          }
          'Fedora': {
            if (versioncmp($::operatingsystemrelease, '21') > 0) {
              $initsystem = 'SystemD'
            } else {
              $initsystem = 'SystemV'
              $versioned_name = "${::operatingsystem} ${::operatingsystemrelease}"
              if jboss_to_bool($jboss::java_autoinstall) {
                warning("Wildfly 10 requires Java 8 or greater, which is not suppoted by default on ${versioned_name}.")
              }
            }
          }
          default: {
            fail("Unsupported OS: ${::operatingsystem}")
          }
        }
      }
      'Debian': {
        case $::lsbdistcodename {
          'lenny','squeeze','lucid','natty','wheezy','precise','quantal','raring','saucy','trusty','utopic' : {
            $initsystem = 'SystemV'
          }
          'jessie','vivid','wily','xenial': {
            $initsystem = 'SystemD'
            $versioned_name = "${::operatingsystem} ${::operatingsystemrelease}"
            if jboss_to_bool($jboss::java_autoinstall) {
              warning("Wildfly 10 requires Java 8 or greater, which is not suppoted by default on ${versioned_name}.")
            }
          }
          default: { fail("Unsupported release ${::lsbdistcodename}") }
        }
      }
      default: {
        fail("Unsupported OS family: ${::osfamily}. Supporting only RHEL and Debian systems. Consult README file.")
      }
    }
  } else {
    # for WFly 8.x, 9.x
    $initsystem = 'SystemV'
    $initd_file = "${jboss::home}/bin/init.d/wildfly-init-${_osfamily_down}.sh"
  }
}
