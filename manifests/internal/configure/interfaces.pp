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
    ensure => 'present',
  }

  if ($enableconsole or $bind_mgmt != undef) and $jboss::internal::runtime::dc::runs_as_controller {
    if $bind_mgmt != undef {
      jboss::interface { "management":
        inet_address => $bind_mgmt,
        any_address  => undef,
      }
    } else {
      jboss::interface { "management":
        any_address  => true,
        inet_address => undef,
      }
    }
  }

  if $bind_public != undef {
    jboss::interface { "public":
      any_address  => undef,
      inet_address => $bind_public,
    }
  } else {
    jboss::interface { "public":
      any_address  => true,
      inet_address => undef,
    }
  }
}