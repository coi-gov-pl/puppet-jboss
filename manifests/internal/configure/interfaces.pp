# Internal class - configure network interfaces
class jboss::internal::configure::interfaces {
  include jboss::params
  include jboss
  include jboss::internal::runtime::dc

  $enableconsole = $jboss::enableconsole
  $runasdomain = $jboss::runasdomain
  $controller = $jboss::controller

  $bind_public = $jboss::params::bind_public
  $bind_mgmt = $jboss::params::bind_mgmt

  Jboss::Interface {
    ensure  => 'present',
  }

  $__console_is_sensible = $jboss::internal::runtime::dc::runs_as_controller or $jboss::runasdomain == false
  if $__console_is_sensible and ($enableconsole or $bind_mgmt != undef){
    if $bind_mgmt != undef {
      jboss::interface { 'management':
        inet_address => $bind_mgmt,
        any_address  => undef,
      }
    } else {
      jboss::interface { 'management':
        any_address  => true,
        inet_address => undef,
      }
    }
  }

  if $bind_public != undef {
    jboss::interface { 'public':
      any_address  => undef,
      inet_address => $bind_public,
    }
  } else {
    jboss::interface { 'public':
      any_address  => true,
      inet_address => undef,
    }
  }
}
