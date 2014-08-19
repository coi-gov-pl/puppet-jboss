/**
 * Creates JBoss domain server group
 */
define jboss::domain::servergroup (
  $ensure                     = 'present',
  $permgensize                = $::jboss::internal::params::memorydefaults::permgensize,
  $maxpermgensize             = $::jboss::internal::params::memorydefaults::maxpermgensize,
  $heapsize                   = $::jboss::internal::params::memorydefaults::heapsize,
  $maxheapsize                = $::jboss::internal::params::memorydefaults::maxheapsize,
  $profile                    = undef,
  $socket_binding_group       = $::jboss::internal::params::socketbinding::group,
  $socket_binding_port_offset = $::jboss::internal::params::socketbinding::port_offset,
  $controller                 = undef,
) {
  include jboss
  
  if $profile == undef {
    $realprofile = $::jboss::profile
  } else {
    $realprofile = $profile
  } 
  
  if $controller == undef {
    $realcontroller = $::jboss::controller
  } else {
    $realcontroller = $controller
  } 
  
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
    controller  => $realcontroller,
    runasdomain => true,
    properties  => {
      'profile'                    => $realprofile, 
      'socket-binding-group'       => $socket_binding_group,
      'socket-binding-port-offset' => $socket_binding_port_offset,
    }
  }
  
  jboss::clientry { "jboss::domain::servergroup::jvm(${name})":
    ensure      => $ensure,
    path        => "/server-group=${name}/jvm=default",
    controller  => $realcontroller,
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