# Creates JBoss domain server group
define jboss::domain::servergroup (
  $ensure                     = 'present',
  $permgensize                = $::jboss::internal::params::memorydefaults::permgensize,
  $maxpermgensize             = $::jboss::internal::params::memorydefaults::maxpermgensize,
  $heapsize                   = $::jboss::internal::params::memorydefaults::heapsize,
  $maxheapsize                = $::jboss::internal::params::memorydefaults::maxheapsize,
  $profile                    = $::jboss::profile,
  $socket_binding_group       = $::jboss::internal::params::socketbinding::group,
  $socket_binding_port_offset = $::jboss::internal::params::socketbinding::port_offset,
  $controller                 = $::jboss::controller,
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
    JBoss::Clientry["jboss::domain::servergroup(${name})"] ->
    JBoss::Clientry["jboss::domain::servergroup::jvm(${name})"]
  } else {
    JBoss::Clientry["jboss::domain::servergroup::jvm(${name})"] ->
    JBoss::Clientry["jboss::domain::servergroup(${name})"]
  }
}


