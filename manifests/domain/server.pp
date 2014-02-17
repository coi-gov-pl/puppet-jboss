include jboss::params
/**
 * Creates JBoss domain server
 */
define jboss::domain::server (
  $group                      = false,
  $ensure                     = 'running',
  $host                       = $name,
  $autostart                  = true,
  $socket_binding_group       = undef,
  $socket_binding_port_offset = 0,
  $controller                 = $jboss::params::controller,
) {
  include jboss
  
  if ! $group and $ensure == 'running' {
    fail("Must pass group to Jboss::Domain::Server[${name}] while ensuring to be `${ensure}`")
  }
  
  $props = {
    'group'                      => $group,
    'auto-start'                 => $autostart, 
    'socket-binding-port-offset' => $socket_binding_port_offset,
  }
  if $socket_binding_group {
    $props['socket-binding-group'] = $socket_binding_group
  }
  case $ensure {
    'running': {}
    'stopped': {}
    'absent':  {}
    'present': {}
    default:   {
      fail("Invalid value for ensure: `${ensure}`. Supported values are: `present`, `absent`, `running`, `stopped`")
    }
  }
  $ensurex = $ensure ? {
    'absent'  => 'absent',
    default   => 'present',
  }
  
  jboss::configuration::node { "jboss::domain::server(${name})":
    ensure       => $ensure,
    path         => "/host=${host}/server-config=${name}",
    controller   => $controller,
    runasdomain  => true,
    properties   => $props,
  }
  
  if $ensurex == 'present' {
    if ! defined(Jboss::Domain::Servergroup[$group]) {
      jboss::domain::servergroup { $group:
        controller => $controller,
        ensure     => $ensurex,
      }
    }
    Jboss::Domain::Servergroup[$group] -> 
    Jboss::Configuration::Node["jboss::domain::server(${name})"]
  }
  
}
