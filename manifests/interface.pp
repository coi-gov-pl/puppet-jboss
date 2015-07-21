define jboss::interface (
  $interface_name     = $name,
  $controller         = $::jboss::controller,
  $runasdomain        = $::jboss::runasdomain,
  $profile            = $::jboss::profile,
  $ensure             = 'present',
  $any_address        = undef, # bool
  $any_ipv4_address   = undef, # bool
  $any_ipv6_address   = undef, # bool
  $inet_address       = undef, # string
  $link_local_address = undef, # bool
  $loopback           = undef, # string
  $loopback_address   = undef, # bool
  $multicast          = undef, # bool
  $nic                = undef, # string
  $nic_match          = undef, # string
  $point_to_point     = undef, # bool
  $public_address     = undef, # bool
  $site_local_address = undef, # bool
  $subnet_match       = undef, # string
  $up                 = undef, # bool
  $virtual            = undef, # bool
  ) {
  include jboss
  include jboss::internal::lenses
  include jboss::internal::runtime

  $bind_variables = {
    'any-address'        => $any_address,       # undef, bool
    'any-ipv4-address'   => $any_ipv4_address,  # undef, bool
    'any-ipv6-address'   => $any_ipv6_address,  # undef, bool
    'inet-address'       => $inet_address,      # '${jboss.bind.address:127.0.0.1}', string
    'link-local-address' => $link_local_address,# undef, bool
    'loopback'           => $loopback,          # undef, string
    'loopback-address'   => $loopback_address,  # undef, bool
    'multicast'          => $multicast,         # undef, bool
    'nic'                => $nic,               # undef, string
    'nic-match'          => $nic_match,         # undef, string
    'point-to-point'     => $point_to_point,    # undef, bool
    'public-address'     => $public_address,    # undef, bool
    'site-local-address' => $site_local_address,# undef, bool
    'subnet-match'       => $subnet_match,      # undef, string
    'up'                 => $up,                # undef, bool
    'virtual'            => $virtual,           # undef, bool
  }

  if str2bool($::jboss_running) {
    Jboss::Clientry {
      ensure      => $ensure,
      controller  => $controller,
      runasdomain => $runasdomain,
      profile     => $profile,
    }
    $entrypath = $runasdomain ? {
      true    => "/host=${jboss::hostname}/interface=${interface_name}",
      default => "/interface=${interface_name}",
    }
    jboss::clientry { $entrypath:
      properties => $bind_variables,
    }
  } else {
    $supported_bind_types = keys($bind_variables)
    $prefixed_bind_types = prefix($supported_bind_types, "${interface_name}:")

    if $runasdomain {
      $cfg_file = $jboss::internal::runtime::hostconfigpath
      $path = 'host/interfaces'
    } else {
      $cfg_file = $jboss::internal::runtime::standaloneconfigpath
      $path = 'server/interfaces'
    }

    validate_absolute_path($cfg_file)

    $augeas_defaults = {
      require   => [
        Anchor['jboss::configuration::begin'],
        File["${jboss::internal::lenses::lenses_path}/jbxml.aug"],
      ],
      notify    => [
        Anchor['jboss::configuration::end'],
        Service[$jboss::product],
      ],
      load_path => $jboss::internal::lenses::lenses_path,
      lens      => 'jbxml.lns',
      context   => "/files${cfg_file}/",
      incl      => $cfg_file,
    }

    if ($ensure == 'present') {
      $augeas_params = merge($augeas_defaults, {
        changes => "set ${path}/interface[last()+1]/#attribute/name ${interface_name}",
        onlyif  => "match ${path}/interface[#attribute/name='${interface_name}'] size == 0",
      })
      ensure_resource('augeas', "ensure present interface ${interface_name}", $augeas_params)
      # For compatibility with puppet 2.x - foreach
      jboss::internal::interface::foreach { $prefixed_bind_types:
        cfg_file        => $cfg_file,
        path            => $path,
        interface_name  => $interface_name,
        bind_variables  => $bind_variables,
        augeas_defaults => $augeas_defaults,
      }
    } else {
      $augeas_params = merge($augeas_defaults, {
        changes => "rm ${path}/interface[#attribute/name='${interface_name}']",
        onlyif  => "match ${path}/interface[#attribute/name='${interface_name}'] size != 0",
      })
      ensure_resource('augeas', "ensure absent interface ${interface_name}", $augeas_params)
    }
  }
}
