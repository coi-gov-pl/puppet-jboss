# == Define: jboss::domain::server
#
# This defined type simplifies creation and removal and updating JBoss domain virtual server (server instance)
# running on a host server (host controller) in domain mode.
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*name*]
#     **This is a namevar**. Standard Puppet namevar indicates name of this virtual server (instance).
# [*group*]
#     This parameter indicates a server group that this virtual server should be member of. If you are setting 
#     `ensure` parameter to `running` this is required to be set.
# [*ensure*]
#     This is standard ensure puppet parameter. It is extended to support also `running` and `stopped` values 
#     as an addition to standard `present` and `absent`.
# [*host*]
#     This parameter indicates a server that should be host (controller) to this virtual server (instance). By
#     default, this is taken from current machine JBoss hostname (`$jboss::hostname` parameter).
# [*autostart*]
#     This parameter indicates whether this virtual server (instance), should be automatically started when
#     host (controller) starts. Be default it is set to `true`.
# [*socket_binding_group*]
#     This parameter indicates that this virtual server should use value of it as socket binding group, By 
#     default it is set to `undef` and not being used.
# [*socket_binding_port_offset*]
#     This parameter indicates offset on JBoss ports, defined by socket binding group. It will shift ports up
#     or down by amount described. The format is simply `n` or `-n`, for example: `120` will shift all ports by
#     120 up making standard http port being now `8080 + 120 = 8200`. By default it is equal to `0`.
#
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
    jboss_hash_setvalue($props, 'socket-binding-group', $socket_binding_group)
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

  if ! jboss_to_bool($::jboss_running) and $ensurex == 'absent' {
    include jboss::internal::augeas
    $cfg_file = $jboss::internal::runtime::hostconfigpath
    $path = 'host/servers'
    $augeas_defaults = merge($jboss::internal::augeas::defaults, {
      context   => "/files${cfg_file}/",
      incl      => $cfg_file,
    })
    $augeas = {
      "ensure absent server ${name}" => merge($augeas_defaults, {
        changes => "rm ${path}/server[#attribute/name='${name}']",
        onlyif  => "match ${path}/server[#attribute/name='${name}'] size != 0",
      })
    }
    create_resources('augeas', $augeas)
  } else {
    jboss::clientry { "jboss::domain::server(${name})":
      ensure      => $ensure,
      path        => "/host=${hostname}/server-config=${name}",
      controller  => $controller,
      runasdomain => true,
      properties  => $props,
    }

    if $ensurex == 'present' {
      if ! defined(Jboss::Domain::Servergroup[$group]) {
        jboss::domain::servergroup { $group:
          ensure     => $ensurex,
          controller => $controller,
        }
      }
      Jboss::Domain::Servergroup[$group] ->
      Jboss::Clientry["jboss::domain::server(${name})"]
    }
  }

}
