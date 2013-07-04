class jboss::download {

  package { "wget":
    ensure => "installed"
  }

notify {"DOWNLOAD:WGET":}
  define download ($uri, $timeout = 300) {
    exec { "download $name":
      command => "wget -q '$uri' -O $name",
      path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      creates => $name,
      timeout => $timeout,
      require => Package[ "wget" ],
    }
  }
}
