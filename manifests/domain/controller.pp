/**
 * class that ensure JBoss runs as domain controller 
 */
class jboss::domain::controller {
  class { 'jboss::internal::runtime::dc':
    runs_as_controller => true,
  }
}