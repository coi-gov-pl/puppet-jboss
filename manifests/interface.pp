# == Define: jboss::interface
#
# This defined type can be used to setup JBoss interfaces. It can add, remove or change
# existing interfaces.
#
# More info about interfaces may be found here: https://docs.jboss.org/author/display/WFLY9/Interfaces+and+ports
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*interface_name*]
#     **This is the namevar**. Name of the interface to manage.
# [*ensure*]
#     Standard ensure parameter. Can be either `present` or `absent`.
#
# === Exclusive parameters
#
# Parameters listed here are exclusive. Only one of them can be set at once.
#
# [*any_address*]
#     This is boolean parameter. If set to `true` JBoss will bind network to any network ip.
#     Bassicly its the same as passing `0.0.0.0` as inet address.
# [*any_ipv4_address*]
#     This is boolean parameter. If set to `true` JBoss will bind network to any ipv4 network ip.
#     It is similar as passing `0.0.0.0` as inet address.
#     This parameter is deprecated for JBoss EAP 7.x and WildFly 9.x and later.
# [*any_ipv6_address*]
#     This is boolean parameter. If set to `true` JBoss will bind network to any ipv6 network ip.
#     It's should be the same as passing `::`.
#     This parameter is deprecated for JBoss EAP 7.x and WildFly 9.x and later.
# [*inet_address*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether or not the address matches the given value. Value is either a IP
#     address in IPv6 or IPv4 dotted decimal notation, or a hostname that can be resolved to an IP
#     address. An `undef` value means this attribute is not relevant to the IP address selection.
#     For ex.: `172.20.0.1`
# [*link_local_addres*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether or not the address is link-local. An `undef` or `false` value
#     means this attribute is not relevant to the IP address selection.
# [*loopback*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether or not it is a loopback address. An `undef` or `false` value
#     means this attribute is not relevant to the IP address selection.
# [*loopback_address*]
#     Attribute indicating that the IP address for this interface should be the given value, if a
#     loopback interface exists on the machine. A 'loopback address' may not actually be configured
#     on the machine's loopback interface. Differs from inet-address in that the given value will
#     be used even if no NIC can be found that has the IP specified address associated with it.
#     An `undef` or `false` value means this attribute is not relevant to the IP address
#     selection. For ex. `127.0.1.1`
# [*multicast*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether or not its network interface supports multicast. An `undef`
#     or `false` value means this attribute is not relevant to the IP address selection.
# [*nic*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether its network interface has the given name. The name of a network
#     interface (e.g. eth0, eth1, lo). An `undef` value means this attribute is not relevant to
#     the IP address selection. For ex.: `eth3`
# [*nic_match*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether its network interface has a name that matches the given regular
#     expression. Value is a regular expression against which the names of the network interfaces
#     available on the machine can be matched to find an acceptable interface. An `undef` value
#     means this attribute is not relevant to the IP ad${home}/bin/add-user.sh --silent --user '${name}'
#     --password \"\$__PASSWD\dress selection. For ex.: `^eth?$`
# [*point_to_point*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether or not its network interface is a point-to-point interface. An
#     `undef` or `false` value means this attribute is not relevant to the IP address selection
# [*public_address*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether or not it is a publicly routable address. An `undef` or `false`
#     value means this attribute is not relevant to the IP address selection
# [*site_local_addres*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether or it is a site-local address. An `undef` or `false` value
#     means this attribute is not relevant to the IP address selection
# [*subnet_match*]
#     Attribite indicating that part of the selection criteria for choosing an IP address for this
#     interface should be evaluated from regular expression against a subnets of all interfaces. An
#     example: `192.168.0.0/24`
# [*up*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether its network interface is currently up. An `undef` or `false`
#     value means this attribute is not relevant to the IP address selection
# [*virtual*]
#     Attribute indicating that part of the selection criteria for choosing an IP address for this
#     interface should be whether its network interface is a virtual interface. An `undef` or
#     `false` value means this attribute is not relevant to the IP address selection
#
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
  $loopback           = undef, # bool
  $loopback_address   = undef, # string
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
  include jboss::internal::augeas
  include jboss::internal::runtime

  $basic_bind_variables = {
    'any-address'        => $any_address,       # undef, bool
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

  $legacy_bind_variables = {
    'any-ipv4-address'   => $any_ipv4_address,  # undef, bool
    'any-ipv6-address'   => $any_ipv6_address,  # undef, bool
  }

  if ($jboss::product == 'wildfly' and versioncmp($jboss::version, '9.0.0') >= 0)
    or ($jboss::product == 'jboss-eap' and versioncmp($jboss::version, '7.0.0') >= 0) {
    $bind_variables = $basic_bind_variables
    $warning_ipv4_before = 'Interface configuration parameter any_ipv4_address is deprecated for'
    $warning_ipv6_before = 'Interface configuration parameter any_ipv6_address is deprecated for'
    if $any_ipv4_address {
      warning("${warning_ipv4_before} ${jboss::product} server version ${jboss::version}. Ignored.")
    }
    if $any_ipv6_address {
      warning("${warning_ipv6_before} ${jboss::product} server version ${jboss::version}. Ignored.")
    }
  }
  else {
    $bind_variables = merge($basic_bind_variables, $legacy_bind_variables)
  }

  if jboss_to_bool($::jboss_running) {
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

    $augeas_defaults = merge($jboss::internal::augeas::defaults, {
      context   => "/files${cfg_file}/",
      incl      => $cfg_file,
    })

    if ($ensure == 'present') {
      $augeas_params = merge($augeas_defaults, {
        changes => "set ${path}/interface[last()+1]/#attribute/name ${interface_name}",
        onlyif  => "match ${path}/interface[#attribute/name='${interface_name}'] size == 0",
      })
      create_resources('augeas', { "ensure present interface ${interface_name}" => $augeas_params })
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
