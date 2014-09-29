class jboss::addons::mod_cluster (
  $version          = $jboss::params::version,
) inherits jboss::params {
  
  include apache
  include jboss::params::mod_cluster
  
  $ver = $jboss::params::mod_cluster::version
  $download_file = "mod_cluster-${ver}-linux2-x64-so.tar.gz"

  package { "$download_file": }
  
  apache::vhost { $::fqdn:
    port    => 10001,
    docroot => '/var/www',
  }
}
