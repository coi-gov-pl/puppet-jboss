## Configure apache to use with mod_cluster.
class jboss::addons::mod_cluster (
  $version          = $::jboss::params::mod_cluster::version,
  $mgmt_ip,
  $modcluster_ip,
) inherits jboss::params {

  # Install RPM containing mod_cluster, then unpack it to the modules directory
  $download_file = "mod_cluster-${version}-linux2-x64-so.tar.gz"
  package { $download_file:
    ensure => 'installed',
  }

  # TODO - probably there's a var for etc/httpd/modules
  exec { 'untar-mod_cluster':
    command     => "/bin/tar -C /etc/httpd/modules -xvf /usr/src/${download_file}",
    subscribe   => Package[$download_file],
    refreshonly => true,
  }

  # mod_cluster module config
  apache::mod { 'slotmem': }
  apache::mod { 'manager': }
  apache::mod { 'proxy': }
  apache::mod { 'proxy_ajp': }
  apache::mod { 'proxy_cluster': }
  apache::mod { 'advertise': }

  # Listening
  #apache::listen { '80': }
  #apache::listen { '81': }
  #apache::listen { '10001': }

  # X-Forwarded-For
  #$log_formats = { vhost_common => '%v %h %l %u %t \"%r\" %>s %b' }

  file { 'mod_cluster_conf':
    path    => '/etc/httpd/conf.d/00-mod_cluster.conf',
    content => '
MemManagerFile /var/cache/httpd
Maxsessionid 100',
  }

  # vhosts
  apache::vhost { 'mgmt-mod_cluster':
    ip              => $mgmt_ip, # Management interface!
    priority        => 30,
    ip_based        => true,
    port            => 10001,
    docroot         => '/var/www/html',
    custom_fragment => template('jboss/mod_cluster_mgmt.conf.erb')
  }

  # vhost for mod_cluster data
  apache::vhost { 'mod_cluster':
    ip              => $modcluster_ip, # internal interface!
    priority        => 30,
    ip_based        => true,
    port            => 10001,
    docroot         => '/var/www/html',
    custom_fragment => template('jboss/mod_cluster_part.conf.erb')
  }

}
