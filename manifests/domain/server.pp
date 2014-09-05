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
  $controller                 = $::jboss::controller,
) {
  include jboss
  
  $host_is_null = $host == undef
  $hostname = $host_is_null ? {
    true    => $jboss::hostname,
    default => $host,
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
  
  if ! str2bool($::jboss_running) and $ensurex == 'absent' {
    include jboss::internal::lenses
    $cfg_file = $jboss::internal::runtime::hostconfigpath
    $path = 'host/servers'
    Augeas {
      require   => [
        Anchor['jboss::configuration::begin'],
        File["${jboss::internal::lenses::lenses_path}/jbxml.aug"],
      ],
      notify    => [
        Anchor['jboss::configuration::end'],
        Service['jboss'],
      ],
      load_path => $jboss::internal::lenses::lenses_path,
      lens      => 'jbxml.lns',
      context   => "/files${cfg_file}/",
      incl      => $cfg_file,
    }
    augeas { "ensure absent server ${name}":
      changes => "rm ${path}/server[#attribute/name='${name}']",
      onlyif  => "match ${path}/server[#attribute/name='${name}'] size != 0",
    }
  } else {
    jboss::clientry { "jboss::domain::server(${name})":
      ensure       => $ensure,
      path         => "/host=${hostname}/server-config=${name}",
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
      Jboss::Clientry["jboss::domain::server(${name})"]
    }
  }
  
}
