define jboss::download (
  $dest = $name,
  $uri,
  $timeout = 300) {
    anchor { "jboss::download::${name}::begin":
    }
    case $uri {
        /^http/: {
            package { "wget":
                ensure => "installed"
            }
            exec { "download ${name}":
                command => "wget -q '$uri' -O ${dest}",
                path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                creates => $dest,
                timeout => $timeout,
                require => [ Package[ "wget" ], Anchor["jboss::download::${name}::begin"], ],
            }
        }
        default: {
            file { "download ${name}":
                name    => $dest,
                source  => $uri,
                require => Anchor["jboss::download::${name}::begin"],
            }
        }
    }
    anchor { "jboss::download::${name}::end":
        require => Anchor["jboss::download::${name}::begin"],
    }
}
