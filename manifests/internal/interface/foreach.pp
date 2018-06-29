# Helper for creating interface children
define jboss::internal::interface::foreach (
  $cfg_file,
  $path,
  $interface_name,
  $bind_variables,
  $augeas_defaults,
  $ensure           = 'present',
) {
  require jboss::internal::lenses

  validate_hash($augeas_defaults)

  $interface_bind_pair = split($name, ':')
  $bind_type = $interface_bind_pair[1]
  $bind_value = $bind_variables[$bind_type]

  if ($bind_value == undef or $ensure != 'present') {
    $augeas_params = merge($augeas_defaults, {
      changes => "rm ${path}/interface[#attribute/name='${interface_name}']/${bind_type}",
      onlyif  => "match ${path}/interface[#attribute/name='${interface_name}']/${bind_type} size != 0",
      require => Augeas["ensure present interface ${interface_name}"],
    })
    $resource_title = "interface ${interface_name} rm ${bind_type}"

  } else {
    $augeas_params = merge($augeas_defaults, {
      changes => "set ${path}/interface[#attribute/name='${interface_name}']/${bind_type}/#attribute/value '${bind_value}'",
      onlyif  => "get ${path}/interface[#attribute/name='${interface_name}']/${bind_type}/#attribute/value != '${bind_value}'",
      require => Augeas["ensure present interface ${interface_name}"],
    })
    $resource_title = "interface ${interface_name} set ${bind_type}"
  }
  ensure_resource('augeas', $resource_title, $augeas_params)
}
