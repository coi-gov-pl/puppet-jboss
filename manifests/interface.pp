define jboss::interface (
  $interface_name     = $name,
  $controller         = $::jboss::controller,
  $runasdomain        = $::jboss::runasdomain,
  $profile            = $::jboss::profile,
  $ensure             = 'present',
  $any_address        = undef, # bool
  $any_ipv4_address   = undef, # bool
  $any_ipv6_address   = undef, # bool
  $inet_address       = '${jboss.bind.address:127.0.0.1}', # string
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
  require jboss::internal::lenses

  $bind_variables = {
    'any-address'        => $any_address, 
    'any-ipv4-address'   => $any_ipv4_address, 
    'any-ipv6-address'   => $any_ipv6_address, 
    'inet-address'       => $inet_address, 
    'link-local-address' => $link_local_address, 
    'loopback'           => $loopback, 
    'loopback-address'   => $loopback_address, 
    'multicast'          => $multicast, 
    'name'               => $interface_name,
    'nic'                => $nic, 
    'nic-match'          => $nic_match, 
    'point-to-point'     => $point_to_point, 
    'public-address'     => $public_address, 
    'site-local-address' => $site_local_address, 
    'subnet-match'       => $subnet_match, 
    'up'                 => $up, 
    'virtual'            => $virtual, # undef, bool
  }

  # Lista wspieranych ustawien - wszystkie poza object chwilowo.
  $supported_bind_types = keys($bind_variables)

  # FIXME: ustalic poprawna nazwe pliku konfiguracyjnego
  # Nie mozna brac z faktu bo moze go jeszcze nie byc...
  if $runasdomain {
    $cfg_file = "${::jboss::home}/domain/configuration/host.xml"
    $path = 'host/interfaces'
  } else {
    $cfg_file = "${::jboss::home}/standalone/configuration/standalone.xml"
    $path = 'server/interfaces'
  }

  Augeas {
    require   => [
      Anchor['jboss::configuration::begin'], 
      File["${::jboss::lenses::lenses_path}/jbxml.aug"],
    ],
    before    => [
      Anchor['jboss::configuration::end'],
      Service['jboss'],
    ],
    load_path => $::jboss::lenses::lenses_path,
    lens      => 'jbxml.lns',
    context   => "/files${cfg_file}/",
    incl      => $cfg_file,
  }

  if ($ensure == 'present') {
    augeas { "ensure present interface ${interface_name}":
      changes => "ins ${path}/interface[#attribute/name='${interface_name}'] before ${path}/interface[0]",
      onlyif  => "match ${path}/interface[#attribute/name='${interface_name}'] size == 0",
    }
    # W oczekiwaniu na puppet 3 trzeba tak (bo nie ma for'a normalnego w 2)
    $prefixed_bind_types = prefix($supported_bind_types, "${interface_name}:")

    jboss::internal::interface_helper { $prefixed_bind_types:
      cfg_file       => $cfg_file,
      path           => $path,
      interface_name => $interface_name,
      bind_variables => $bind_variables,
    }
  } else {
    augeas { "ensure absent interface ${interface_name}":
      changes => "rm ${path}/interface[#attribute/name='${interface_name}']",
      onlyif  => "match ${path}/interface[#attribute/name='${interface_name}'] size != 0",
    }
  }
  
}

# Helper for creating interface children
define jboss::internal::interface_helper (
  $cfg_file,
  $path,
  $interface_name,
  $bind_variables,
  $ensure      = 'present',
  $runasdomain = $::jboss::runasdomain,
  $home        = $::jboss::home,) {
  require jboss::internal::lenses

  Augeas {
    require => Augeas["ensure present interface ${interface_name}"], }

  $interface_bind_pair = split($name, ':')
  $bind_type = $interface_bind_pair[1]
  $bind_value = $bind_variables[$bind_type]

  if ($bind_value == undef or $ensure != 'present') {
    augeas { "interface ${interface_name} rm ${bind_type}":
      changes => "rm ${path}/interface[#attribute/name='${interface_name}']/${bind_type}",
      onlyif  => "match ${path}/interface[#attribute/name='${interface_name}']/${bind_type} size != 0",
    }
  } else {
    augeas { "interface ${interface_name} set ${bind_type}":
      changes => "set ${path}/interface[#attribute/name='${interface_name}']/${bind_type}/#attribute/value '${bind_value}'",
      onlyif  => "get ${path}/interface[#attribute/name='${interface_name}']/${bind_type}/#attribute/value != '${bind_value}'",
    }
    # notify{"Set ${interface_name}/${bind_type} to ${bind_value}, file ${cfg_file}, path ${path}":}
  }
}

