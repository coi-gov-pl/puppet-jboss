class jboss::internal::configure::interfaces {
  include jboss::params
  include jboss

  $enableconsole = $jboss::enableconsole
  $runasdomain   = $jboss::runasdomain

  $bind_public   = $jboss::params::bind_public
  $bind_mgmt     = $jboss::params::bind_mgmt

  if $enableconsole {
    if $bind_mgmt == undef {
      $manageprops = {
        'inet-address' => undef,
        'any-address'  => true,
      }
    } else {
      $manageprops = {
        'inet-address' => $bind_mgmt,
        'any-address'  => undef,
      }
    }
  } else {
    $manageprops = {
      'inet-address' => "\${jboss.bind.address.management:127.0.0.1}",
      'any-address'  => undef,
    }
  }

  if $runasdomain {
    $managementPath = "/host=${jboss::hostname}/interface=management"
    $publicPath = "/host=${jboss::hostname}/interface=public"
  } else {
    $managementPath = '/interface=management'
    $publicPath = "/interface=public"
  }

  if $bind_public == undef {
    jboss::clientry { 'jboss::configuration::public::inet-address':
      ensure     => 'present',
      path       => $publicPath,
      properties => {
        'inet-address' => undef,
      },
    } ->
    jboss::clientry { 'jboss::configuration::public::any-address':
      ensure     => 'present',
      path       => $publicPath,
      properties => {
        'any-address' => true,
      },
    }
  } else {
    jboss::clientry { 'jboss::configuration::public::any-address':
      ensure     => 'present',
      path       => $publicPath,
      properties => {
        'any-address' => undef,
      },
    } ->
    jboss::clientry { 'jboss::configuration::public::inet-address':
      ensure     => 'present',
      path       => $publicPath,
      properties => {
        'inet-address' => $bind_public,
      },
    }
  }

  jboss::clientry { 'jboss::configuration::management::inet-address':
    ensure     => 'present',
    path       => $managementPath,
    properties => {
      'inet-address' => $manageprops['inet-address'],
    },
  }
  jboss::clientry { 'jboss::configuration::management::any-address':
    ensure     => 'present',
    path       => $managementPath,
    properties => {
      'any-address'  => $manageprops['any-address'],
    },
  }

  if $enableconsole {
    Jboss::Clientry['jboss::configuration::management::inet-address'] ->
    Jboss::Clientry['jboss::configuration::management::any-address']
  } else {
    Jboss::Clientry['jboss::configuration::management::any-address'] ->
    Jboss::Clientry['jboss::configuration::management::inet-address']
  }
}