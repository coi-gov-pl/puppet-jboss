# == Define: jboss::domain::servergroup
#
# This defined type simplifies creation and removal and updating JBoss domain server group that can enforce
# same configuration (profile, deployments and JVM settings) across multiple servers on multiple host
# controllers. This is only possible in domain mode.
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*ensure*]
#     Standard Puppet ensure parameter with values `present` and `absent`
# [*permgensize*]
#     This parameters configures JVM PermGen minimal size, By default it is equal to `32m`
# [*maxpermgensize*]
#     This parameters configures JVM PermGen maximal size, By default it is equal to `256m`
# [*heapsize*]
#     This parameters configures JVM Heap minimal size, By default it is equal to `256m`
# [*maxheapsize*]
#     This parameters configures JVM Heap maximal size, By default it is equal to `1303m`
# [*profile*]
#     This parameter configure profile to be active on all servers within this group. By default
#     it is equal to value of `$jboss::profile`.
# [*socket_binding_group*]
#     This parameter indicates that server instances within this group should use value of it as socket
#     binding group, By default it is set to `full-sockets`.
# [*socket_binding_port_offset*]
#     This parameter indicates offset on JBoss ports, defined by socket binding group. It will shift ports up
#     or down by amount described. The format is simply `n` or `-n`, for example: `120` will shift all ports by
#     120 up making standard http port being now `8080 + 120 = 8200`. By default it is equal to `0`.
# [*system_properties*]
#     This parameter can be used to set system properties that will be passed to server instance java
#     process as `-D` parameters. It's empty by default.
# [*jvmopts*]
#     This property can be set to configure additional JVM options to be passed to server instances in
#     addition to standard memory configuration.
#
define jboss::domain::servergroup (
  $ensure                     = 'present',
  $permgensize                = $::jboss::internal::params::memorydefaults::permgensize,
  $maxpermgensize             = $::jboss::internal::params::memorydefaults::maxpermgensize,
  $heapsize                   = $::jboss::internal::params::memorydefaults::heapsize,
  $maxheapsize                = $::jboss::internal::params::memorydefaults::maxheapsize,
  $profile                    = $jboss::profile,
  $socket_binding_group       = $::jboss::internal::params::socketbinding::group,
  $socket_binding_port_offset = $::jboss::internal::params::socketbinding::port_offset,
  $controller                 = $jboss::controller,
  $system_properties          = {},
  $jvmopts                    = undef,
) {
  include jboss

  case $ensure {
    'absent':  {}
    'present': {}
    default:   {
      fail("Invalid value for ensure: `${ensure}`. Supported values are: `present`, `absent`")
    }
  }

  jboss::clientry { "jboss::domain::servergroup(${name})":
    ensure      => $ensure,
    path        => "/server-group=${name}",
    controller  => $controller,
    runasdomain => true,
    properties  => {
      'profile'                    => $profile,
      'socket-binding-group'       => $socket_binding_group,
      'socket-binding-port-offset' => $socket_binding_port_offset,
    }
  }

  $jvmopts_set = $jvmopts != undef
  $jvmopts_str = $jvmopts_set ? {
    true    => $jvmopts,
    default => undef,
  }

  $jvmproperties = {
    'heap-size'        => $heapsize,
    'max-heap-size'    => $maxheapsize,
    'max-permgen-size' => $maxpermgensize,
    'jvm-options'      => $jvmopts_str,
  }

  jboss::clientry { "jboss::domain::servergroup::jvm(${name})":
    ensure      => $ensure,
    path        => "/server-group=${name}/jvm=default",
    controller  => $controller,
    runasdomain => true,
    properties  => $jvmproperties
  }

  #Prepend server group name to each system property. Result is 'group:property'
  $system_properties_keys = regsubst(keys($system_properties), '^(.*)$', "${name}~~~\\1")
  jboss::internal::domain::servergroup::foreach { $system_properties_keys:
    ensure     => $ensure,
    map        => $system_properties,
    group      => $name,
    profile    => $profile,
    controller => $controller,
  }

  if $ensure == 'present' {
    JBoss::Clientry["jboss::domain::servergroup(${name})"] -> JBoss::Clientry["jboss::domain::servergroup::jvm(${name})"]
  } else {
    JBoss::Clientry["jboss::domain::servergroup::jvm(${name})"] -> JBoss::Clientry["jboss::domain::servergroup(${name})"]
  }
}
