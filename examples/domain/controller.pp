# This include must be defined before JBoss main class
include jboss::domain::controller

class { 'jboss':
  enableconsole => true,
}