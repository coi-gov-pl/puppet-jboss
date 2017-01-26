# == Class: jboss::internal::compatibility::eap
# This is internal class to resolve JBoss EAP compatibility
class jboss::internal::compatibility::eap {
  include jboss

  if versioncmp($jboss::version, '6.0.0') < 0 or versioncmp($jboss::version, '8.0.0') >= 0 {
    fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: JBoss EAP 6.x and 7.x series")
  }

  $product_short = 'jboss'
  $expect_to_start = true

  if versioncmp($jboss::version, '7.0.0') >= 0 {
    # after EAP 7.x
    $controller_port  = '9990'
    $initd_file       = "${jboss::home}/bin/init.d/jboss-eap-rhel.sh"
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
            }
          }
          'Fedora': {
            if (versioncmp($::operatingsystemrelease, '21') > 0) {
              $initsystem = 'SystemD'
            } else {
              $initsystem = 'SystemV'
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
          'jessie','vivid','wily','xenial','yakkety','zesty': {
            $initsystem = 'SystemD'
          }
          default: { fail("Unsupported release ${::lsbdistcodename}") }
        }
      }
      default: {
        fail("Unsupported OS family: ${::osfamily}. Supporting only RHEL and Debian systems. Consult README file.")
      }
    }
  } else {
    # before EAP 7.x
    $controller_port  = '9999'
    $initsystem       = 'SystemV'
    $initd_file       = $jboss::runasdomain ? {
      true    => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
      default => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
    }
  }
}
