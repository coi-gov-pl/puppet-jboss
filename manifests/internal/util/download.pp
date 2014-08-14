define jboss::internal::util::download (
  $uri, 
  $dest = $name, 
  $timeout = 900,
) {
  anchor { "jboss::download::${name}::begin": }

  case $uri {
    /^(?:http|ftp)s?:/ : {
      if ! defined(Package['wget']) {
        package { 'wget': ensure => "installed" }
      }

      exec { "download ${name}":
        command => "wget -q '$uri' -O ${dest}",
        path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        creates => $dest,
        timeout => $timeout,
        require => [
          Package["wget"], 
          Anchor["jboss::download::${name}::begin"],
        ],
        before  => Anchor["jboss::download::${name}::end"], 
      }
    }
    default : {
      file { "download ${name}":
        path    => $dest,
        source  => $uri,
        require => Anchor["jboss::download::${name}::begin"],
        before  => Anchor["jboss::download::${name}::end"],
      }
    }
  }

  anchor { "jboss::download::${name}::end": 
    require => Anchor["jboss::download::${name}::begin"], 
  }
}

