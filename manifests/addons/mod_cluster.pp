class jboss::addons::mod_cluster (
  $version          = $jboss::params::version,
) inherits jboss::params {
  
  include apache
  include jboss::params::mod_cluster
  
  $download_rootdir = $jboss::internal::params::download_rootdir
  $ver = $jboss::params::mod_cluster::version
  $download_dir = "${$download_rootdir}/mod_cluster-${ver}"
  $download_file = "mod_cluster-${ver}-linux2-x64-so.tar.gz"
  $download_url = "http://downloads.jboss.org/mod_cluster//${ver}/linux-x86_64/${download_file}"
  
  file {$download_dir:
    ensure => 'directory',
  }
  
  jboss::internal::util::download { "${download_dir}/${download_file}":
    uri     => $download_url,
    require => File[$download_dir],
  }
  
  apache::vhost { $::fqdn:
    port    => 10001,
    docroot => '/var/www',
  }
}