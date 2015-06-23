# Helper for creating interface children
define jboss::internal::interface::foreach (
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
  }
}
