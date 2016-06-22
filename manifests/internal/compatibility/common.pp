# == Class: jboss::internal::compatibility::common
# This is internal class to resolve common compatibility variables
class jboss::internal::compatibility::common {
  $osfamily_down = downcase($::osfamily)
}
