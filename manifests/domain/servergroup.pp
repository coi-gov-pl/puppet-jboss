include jboss::params
include jboss::internal::params::memorydefaults
include jboss::internal::params::socketbinding

/**
 * Creates JBoss domain server group
 */
define jboss::domain::servergroup (
  $ensure                     = 'present',
  $permgensize                = $jboss::internal::params::memorydefaults::permgensize,
  $maxpermgensize             = $jboss::internal::params::memorydefaults::maxpermgensize,
  $heapsize                   = $jboss::internal::params::memorydefaults::heapsize,
  $maxheapsize                = $jboss::internal::params::memorydefaults::maxheapsize,
  $profile                    = $jboss::params::profile,
  $socket_binding_group       = $jboss::internal::params::socketbinding::group,
  $socket_binding_port_offset = $jboss::internal::params::socketbinding::port_offset,
  $controller                 = $jboss::params::controller,
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
  
  jboss::clientry { "jboss::domain::servergroup::jvm(${name})":
    ensure      => $ensure,
    path        => "/server-group=${name}/jvm=default",
    controller  => $controller,
    runasdomain => true,
    properties  => {
      'heap-size'        => $heapsize, 
      'max-heap-size'    => $maxheapsize,
      'max-permgen-size' => $maxpermgensize,
    }
  }
  
  if $ensure == 'present' {
    JBoss::Clientry["jboss::domain::servergroup(${name})"] ->
    JBoss::Clientry["jboss::domain::servergroup::jvm(${name})"]
  } else {
    JBoss::Clientry["jboss::domain::servergroup::jvm(${name})"] ->
    JBoss::Clientry["jboss::domain::servergroup(${name})"]
  }
}