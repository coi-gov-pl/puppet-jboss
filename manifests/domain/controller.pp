# == Class: jboss::domain::controller
#
# This class will setup JBoss server to run as controller of the domain. It has no parameters.
#
class jboss::domain::controller {
  class { 'jboss::internal::runtime::dc':
    runs_as_controller => true,
  }
}
