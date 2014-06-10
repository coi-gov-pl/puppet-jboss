/**
 * Deprecated!
 * 
 * DO NOT USE THIS RESOURCE, IT WILL BE REMOVED!
 */
define jboss::xml::host (
  $ensure  = 'present',
  $path    = $name,
  $content = undef,
  $active  = true,
) {
  include jboss
  
  $file_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }
  
  $host_config = jboss_basename($path)
  if $content {
    file { "jboss::xml::host::${name}":
      path    => "${jboss::home}/domain/configuration/${host_config}_staged",
      ensure  => $file_ensure,
      content => $content,
      require => Anchor['jboss::configuration::begin'],
    }
  } else {
    file { "jboss::xml::host::${name}":
      path    => "${jboss::home}/domain/configuration/${host_config}_staged",
      ensure  => $file_ensure,
      source  => $path,
      require => Anchor['jboss::configuration::begin'],
    }
  }
  
  if $file_ensure == 'file' {
    File["jboss::xml::host::${name}"] ~> Exec["jboss::xml::host::overwrite::${name}"]
    
    if $active {
      concat::fragment { "jboss::jboss-as.conf::xml::host::${name}":
        target  => "/etc/jboss-as/jboss-as.conf",
        order   => '020',
        notify  => Service['jboss'],
        content => template('jboss/xml/jboss-as.conf_host.erb'),
      }
    }
    file { "${jboss::home}/domain/configuration/${host_config}":
      ensure  => 'file',
      owner   => 'root',
      group   => 'jboss',
      mode    => '640',
      require => Exec["jboss::xml::host::overwrite::${name}"],
    }
  } else {
    file { "${jboss::home}/domain/configuration/${host_config}":
      ensure  => 'absent',
    }
  }
  # hack: nie nadpisuj pliku króry lokalnie się zmienił, ale jeśli w puppecie się zmienił to nadpisz.
  exec { "jboss::xml::host::overwrite::${name}":
    refreshonly => true,
    command     => "/bin/cp -f ${jboss::home}/domain/configuration/${host_config}_staged ${jboss::home}/domain/configuration/${host_config}",
    notify      => Service['jboss'],
    require     => Anchor['jboss::configuration::begin'],
  }
}
