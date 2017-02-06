# == Class: jboss::internal::compatibility::initsystem
# INTERNAL CLASS!
#
class jboss::internal::compatibility::initsystem {
  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'RedHat', 'CentOS', 'OracleLinux', 'Scientific', 'OEL': {
          if (versioncmp($::operatingsystemrelease, '7.0') >= 0) {
            $initsystem = 'SystemD'
          } else {
            $initsystem = 'SystemV'
          }
        }
        'Fedora': {
          if (versioncmp($::operatingsystemrelease, '21') >= 0) {
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
      case $::operatingsystem {
        'Ubuntu': {
          if (versioncmp($::operatingsystemrelease, '15.04') >= 0) {
            $initsystem = 'SystemD'
          } else {
            $initsystem = 'SystemV'
          }
        }
        'Debian': {
          if (versioncmp($::operatingsystemrelease, '8') >= 0) {
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
    default: {
      fail("Unsupported OS family: ${::osfamily}. Supporting only RHEL and Debian systems. Consult README file.")
    }
  }
}
