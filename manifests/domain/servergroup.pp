include jboss::params
/**
 * Creates JBoss domain server group
 */
define jboss::domain::servergroup (
  $ensure                     = 'present',
  $maxpermgensize             = '256m',
  $heapsize                   = '1303m',
  $maxheapsize                = '1303m',
  $profile                    = $jboss::params::profile,
  $socket_binding_group       = 'full-sockets',
  $socket_binding_port_offset = 0,
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
  
  jboss::configuration::node { "jboss::domain::servergroup(${name})":
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
  
  jboss::configuration::node { "jboss::domain::servergroup::jvm(${name})":
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
    JBoss::Configuration::Node["jboss::domain::servergroup(${name})"] ->
    JBoss::Configuration::Node["jboss::domain::servergroup::jvm(${name})"]
  } else {
    JBoss::Configuration::Node["jboss::domain::servergroup::jvm(${name})"] ->
    JBoss::Configuration::Node["jboss::domain::servergroup(${name})"]
  }
}