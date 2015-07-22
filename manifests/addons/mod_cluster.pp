## Configure apache to use with mod_cluster.
class jboss::addons::mod_cluster (
  $mgmt_ip,
  $modcluster_ip,
  $version          = $::jboss::params::mod_cluster::version,
  $fetch_tool       = undef,
) inherits jboss::params {

  include jboss::params
  include jboss::params::mod_cluster

  # Install RPM containing mod_cluster, then unpack it to the modules directory

  $download_rootdir = $jboss::params::download_rootdir
  $ver              = $jboss::params::mod_cluster::version
  $download_dir     = "${$download_rootdir}/mod_cluster-${ver}"
  $download_file    = "mod_cluster-${ver}-linux2-x64-so.tar.gz"
  $download_url     = "http://downloads.jboss.org/mod_cluster//${ver}/linux-x86_64/${download_file}"

  file { $download_dir:
    ensure => 'directory',
  }

  $apache_service  = getvar('apache::apache_name')
  $apache_dir      = getvar('apache::httpd_dir')
  $apache_lib_path = getvar('apache::lib_path')

  validate_absolute_path($apache_dir)
  $apache_full_lib_path = "${apache_dir}/${apache_lib_path}"
  validate_absolute_path($apache_full_lib_path)

  jboss::internal::util::fetch::file { $download_file:
    fetch_tool => $fetch_tool,
    fetch_dir  => $download_dir,
    address    => $download_url,
    require    => File[$download_dir],
  }

  exec { 'untar-mod_cluster':
    path      => $::path,
    command   => "/bin/tar -C ${apache_full_lib_path} -xvf ${download_dir}/${download_file}",
    onlyif    => "[ ! -f ${apache_full_lib_path}/mod_proxy_cluster.so ] || [ \"${download_dir}/${download_file}\" -nt \"${apache_full_lib_path}/mod_proxy_cluster.so\" ]",
    subscribe => Jboss::Internal::Util::Fetch::File[$download_file],
    notify    => Service[$apache_service],
  }

  # mod_cluster module config
  create_resources('apache::mod', {
    'slotmem'       => {},
    'manager'       => {},
    'proxy'         => {},
    'proxy_ajp'     => {},
    'proxy_cluster' => {},
    'advertise'     => {},
  })

  # Listening
#  create_resources('apache::listen', {
#    '80'    => {},
#    '81'    => {},
#    '10001' => {},
#  })

  # X-Forwarded-For
  #$log_formats = { vhost_common => '%v %h %l %u %t \"%r\" %>s %b' }


  file { 'mod_cluster_conf':
    path    => '/etc/httpd/conf.d/00-mod_cluster.conf',
    notify  => Service[$apache_service],
    content => '
MemManagerFile /var/cache/httpd
Maxsessionid 100',
  }

  $ipaddress_re = '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'
  validate_re($mgmt_ip, $ipaddress_re)
  validate_re($modcluster_ip, $ipaddress_re)

  # vhosts
  create_resources('apache::vhost', {
    'mgmt-mod_cluster' => {
      ip              => $mgmt_ip, # Management interface!
      priority        => 30,
      ip_based        => true,
      port            => 10001,
      docroot         => '/var/www/html',
      custom_fragment => template('jboss/mod_cluster_mgmt.conf.erb')
    },
    # vhost for mod_cluster data
    'mod_cluster'      => {
      ip              => $modcluster_ip, # internal interface!
      priority        => 30,
      ip_based        => true,
      port            => 10001,
      docroot         => '/var/www/html',
      custom_fragment => template('jboss/mod_cluster_part.conf.erb')
    }
  })
}
