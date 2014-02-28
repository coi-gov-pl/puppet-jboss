# == Class: prerequisites
#
# Ensure any required dependencies for jboss installaction are present.
#
# Parameters:
#
# None
#
class jboss::prerequisites {
  if ! defined(Package['unzip']) {
    package { "unzip": ensure => "latest" }
  }
}
