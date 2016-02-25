# Internal class - one line in .conf file
define jboss::internal::configure::conf_entry(
  $value,
  $ensure   = undef,
  $variable = $name,
) {
  include jboss::internal::runtime

  if $ensure == undef {
    $auto_ensure = $value ? {
      undef   => absent,
      ''      => absent,
      default => present,
    }
  } else {
    $auto_ensure = $ensure
  }

  $configfile  = $jboss::internal::runtime::binconfigpath
  $marker      = "### PUPPET_${variable}_MARKER ###"

  file_line { "${configfile}: ${variable}=${value}":
    ensure => $auto_ensure,
    path   => $configfile,
    line   => "${variable}=\"${value}\" ${marker}",
    match  => "\\s*${variable}=.*${marker}",
  }

}
