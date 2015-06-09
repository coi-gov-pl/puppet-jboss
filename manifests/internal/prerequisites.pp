# == Class: prerequisites
#
# Ensure any required dependencies for jboss installaction are present.
#
# Parameters:
#
# None
#
class jboss::internal::prerequisites {
  if ! defined(Package['unzip']) {
    ensure_packages('unzip')
  }
}
