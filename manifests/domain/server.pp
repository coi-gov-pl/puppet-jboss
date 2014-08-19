/**
 * Creates JBoss domain server
 */
define jboss::domain::server (
  $group                      = false,
  $ensure                     = 'running',
  $host                       = undef,
  $autostart                  = true,
  $socket_binding_group       = undef,
  $socket_binding_port_offset = $::jboss::internal::params::socketbinding::port_offset,
  $controller                 = undef,
) {
  include jboss
  
  $host_is_null = $host == undef
  $hostname = $host_is_null ? {
    true    => $jboss::hostname,
    default => $host,
  }
  
  if $controller == undef {
    $realcontroller = $::jboss::controller
  } else {
    $realcontroller = $controller
  } 
  
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
  
  jboss::clientry { "jboss::domain::server(${name})":
    ensure       => $ensure,
    path         => "/host=${hostname}/server-config=${name}",
    controller   => $realcontroller,
    runasdomain  => true,
    properties   => $props,
  }
  
  if $ensurex == 'present' {
    if ! defined(Jboss::Domain::Servergroup[$group]) {
      jboss::domain::servergroup { $group:
        controller => $realcontroller,
        ensure     => $ensurex,
      }
    }
    Jboss::Domain::Servergroup[$group] -> 
    Jboss::Clientry["jboss::domain::server(${name})"]
  }
  
}
