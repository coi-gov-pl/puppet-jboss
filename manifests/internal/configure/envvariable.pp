# @summary Configures environmental variable
# @api private
define jboss::internal::configure::envvariable (
  $values,
  $variable = $name,
  ) {
  # resources
  include jboss

  $mode   = $jboss::runasdomain ? {
    true  => 'domain',
    false => 'standalone',
  }
  $config = "${jboss::home}/bin/${mode}.conf"
  $value  = $values[$variable]
  $marker = "### Puppet configured variable ${variable}. Do not edit manually."

  file_line { "${config}: ${variable}=${value}":
    ensure  => 'present',
    path    => $config,
    line    => "${variable}=\"${value}\" ${marker}",
    match   => "${variable}=\".*\" ${marker}",
    require => Anchor['jboss::configuration::begin'],
    notify  => Service[$jboss::product],
    before  => Anchor['jboss::configuration::end'],
  }
}
