define jboss::xml::host (
  $ensure = 'present',
  $path   = $name,
  $content = undef,
) {
  
  $file_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }
  
  $host_config = basename($path)
  if $content {
    file { "jboss::xml::host::${name}":
      path    => "${::jboss_home}/domain/configuration/${host_config}_staged",
      ensure  => $file_ensure,
      content => $content,
      require => Anchor['jboss::package::end'],
    }
  } else {
    file { "jboss::xml::host::${name}":
      path    => "${::jboss_home}/domain/configuration/${host_config}_staged",
      ensure  => $file_ensure,
      source  => $path,
      require => Anchor['jboss::package::end'],
    }
  }
  
  if $file_ensure == 'file' {
    File["jboss::xml::host::${name}"] ~> Exec["jboss::xml::host::overwrite::${name}"]
  }
  # hack: nie nadpisuj pliku króry lokalnie się zmienił, ale jeśli w puppecie się zmienił to nadpisz.
  exec { "jboss::xml::host::overwrite::${name}":
    refreshonly => true,
    command     => "/bin/cp -f ${::jboss_home}/domain/configuration/${host_config}_staged ${::jboss_home}/domain/configuration/${host_config}",
    notify      => Service['jboss'],
    require     => Anchor['jboss::package::end'],
  }
}
