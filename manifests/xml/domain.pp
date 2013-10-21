define jboss::xml::domain (
  $ensure = 'present',
  $path   = $name,
  $content = undef,
) {
  include jboss
  
  $file_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }
  
  $domain_config = jboss_basename($path)
  if $content {
    file { "jboss::xml::domain::${name}":
      path    => "${jboss::home}/domain/configuration/${domain_config}_staged",
      ensure  => $file_ensure,
      content => $content,
      require => Anchor['jboss::package::end'],
    }
  } else {
    file { "jboss::xml::domain::${name}":
      path    => "${jboss::home}/domain/configuration/${domain_config}_staged",
      ensure  => $file_ensure,
      source  => $path,
      require => Anchor['jboss::package::end'],
    }
  }
  
  if $file_ensure == 'file' {
    File["jboss::xml::domain::${name}"] ~> Exec["jboss::xml::domain::overwrite::${name}"]
  }
  # hack: nie nadpisuj pliku króry lokalnie się zmienił, ale jeśli w puppecie się zmienił to nadpisz.
  exec { "jboss::xml::domain::overwrite::${name}":
    refreshonly => true,
    command     => "/bin/cp -f ${jboss::home}/domain/configuration/${domain_config}_staged ${jboss::home}/domain/configuration/${domain_config}",
    notify      => Service['jboss'],
    require     => Anchor['jboss::package::end'],
  }
}