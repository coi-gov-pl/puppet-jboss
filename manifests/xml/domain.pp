define jboss::xml::domain (
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
  
  $domain_config = jboss_basename($path)
  if $content {
    file { "jboss::xml::domain::${name}":
      path    => "${jboss::home}/domain/configuration/${domain_config}_staged",
      ensure  => $file_ensure,
      content => $content,
      require => Anchor['jboss::configuration::begin'],
    }
  } else {
    file { "jboss::xml::domain::${name}":
      path    => "${jboss::home}/domain/configuration/${domain_config}_staged",
      ensure  => $file_ensure,
      source  => $path,
      require => Anchor['jboss::configuration::begin'],
    }
  }
  
  if $file_ensure == 'file' {
    File["jboss::xml::domain::${name}"] ~> Exec["jboss::xml::domain::overwrite::${name}"]
    
    if $active {
      concat::fragment { "jboss::jboss-as.conf::xml::domain::${name}":
        target  => "/etc/jboss-as/jboss-as.conf",
        order   => '010',
        notify  => Service['jboss'],
        content => template('jboss/xml/jboss-as.conf_domain.erb'),
      }
    }
    file { "${jboss::home}/domain/configuration/${domain_config}":
      ensure  => 'file',
      owner   => 'root',
      group   => 'jboss',
      mode    => '640',
      require => Exec["jboss::xml::domain::overwrite::${name}"],
    }
  } else {
    file { "${jboss::home}/domain/configuration/${domain_config}":
      ensure  => 'absent',
    }
  }
  # hack: nie nadpisuj pliku króry lokalnie się zmienił, ale jeśli w puppecie się zmienił to nadpisz.
  exec { "jboss::xml::domain::overwrite::${name}":
    refreshonly => true,
    command     => "/bin/cat ${jboss::home}/domain/configuration/${domain_config}_staged > ${jboss::home}/domain/configuration/${domain_config}",
    notify      => Service['jboss'],
    require     => Anchor['jboss::configuration::begin'],
  }
}