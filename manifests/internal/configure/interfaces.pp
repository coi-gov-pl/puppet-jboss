class jboss::internal::configure::interfaces {
  include jboss::params
  include jboss

  $enableconsole = $jboss::enableconsole
  $runasdomain = $jboss::runasdomain

  $bind_public = $jboss::params::bind_public
  $bind_mgmt = $jboss::params::bind_mgmt

  if $enableconsole {
    if $bind_mgmt == undef {
      jboss::interface { "management":
        any_address  => true,
        inet_address => undef,
      }
    } else {
      jboss::interface { "management":
        any_address  => undef,
        inet_address => $bind_mgmt,
      }
    }
  }

  if $bind_public == undef {
    jboss::interface { "public":
      any_address  => true,
      inet_address => undef,
    }
  } else {
    jboss::interface { "public":
      any_address  => undef,
      inet_address => $bind_public,
    }
  }
}