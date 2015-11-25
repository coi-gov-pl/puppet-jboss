# == Class: jboss::domain::controller
#
# This class will setup parameters for JBoss server to run as controller of the domain. It 
# has no parameters. This class must be used before main JBoss class fo ex.:
#
#   include jboss::domain::controller
#   class { 'jboss':
#     enableconsole => true,
#   }
#
class jboss::domain::controller {
  class { 'jboss::internal::runtime::dc':
    runs_as_controller => true,
  }
}
