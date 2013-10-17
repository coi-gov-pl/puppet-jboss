class jboss::package (
  $jboss_user   = $jboss::params::jboss_user,
  $jboss_group  = $jboss::params::jboss_group,
  $download_url = $jboss::params::download_url,
  $version      = $jboss::params::version,
  $java_install = $jboss::params::java_install,
  $java_version = $jboss::params::java_version,
  $java_package = $jboss::params::java_package,
  $install_dir  = $jboss::params::install_dir,
) inherits jboss::params {
  $download_file = basename($download_url)
  $download_dir = "/usr/src/download-jboss-${version}"

  anchor { "jboss::package::begin": }

  $jboss_home = "$install_dir/jboss-${version}"

  File {
    owner => $jboss_user,
    group => $jboss_group,
    mode  => '2750',
  }

  Exec {
    path      => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    logoutput => 'on_failure',
  }

  if (!defined(Group[$jboss_group])) {
    group { $jboss_group: ensure => 'present', }
  }

  if (!defined(User[$jboss_user])) {
    user { $jboss_user:
      ensure     => 'present',
      managehome => true,
      gid        => $jboss_group,
    }
  }

  file { $install_dir:
    ensure => 'directory',
    owner  => undef,
    group  => undef,
    mode   => undef,
  }

  file { 'jboss::/etc/jboss-as':
    path   => '/etc/jboss-as',
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '755',
  }
  
  if $java_install {
    class { 'java':
      distribution => 'jdk',
      version      => $java_version,
      package      => $java_package,
    }
  }

  file { $download_dir: 
    ensure => 'directory', 
  }

  jboss::download { "${download_dir}/${download_file}":
    uri     => $download_url,
    require => File[$download_dir],
  }
  
  if ! defined(Package['unzip']) {
    package { "unzip": ensure => "latest" }
  }

  exec { 'jboss::unzip-downloaded':
    command => "unzip -o -q ${download_dir}/${download_file} -d ${download_dir}",
    cwd     => $download_dir,
    unless  => "find ${download_dir} -type f -name jboss-as-domain.sh | grep jboss-as-domain.sh",
    require => [
      Jboss::Download["${download_dir}/${download_file}"], 
      File[$download_dir], 
      Package['unzip'],
    ],
  }

  exec { 'jboss::move-unzipped':
    command => "mv $(find ${download_dir}/ -maxdepth 1 -type d -print | egrep -v '(/|\\.)$') ${jboss_home}",
    creates => $jboss_home,
    require => Exec['jboss::unzip-downloaded'],
  }

  exec { 'jboss::test-extraction':
    command => "echo '${jboss_home}/bin/init.d not found!' 1>&2 && exit 1",
    unless  => "test -d ${jboss_home}/bin/init.d",
    require => Exec['jboss::move-unzipped'],
  }

  jboss::util::setgroupaccess { $jboss_home:
    user    => $jboss_user,
    group   => $jboss_group,
    require => [
      User[$jboss_user], 
      Exec['jboss::test-extraction'],
    ],
  }

  file { 'jboss::service-link':
    ensure  => 'link',
    target  => '/etc/init.d/jboss',
    path    => "${jboss_home}/bin/init.d/jboss-as-domain.sh",
    require => Jboss::Util::Setgroupaccess[$jboss_home],
  }
  
  if ($host_xml) {
    $host_config = basename($host_xml)

    file { 'custom jboss host.xml':
      path    => "${jboss_home}/domain/configuration/${host_config}",
      ensure  => 'present',
      source  => $host_xml,
      notify  => Service['jboss'],
      before  => [
        File['jboss-as-conf'],
      ],
      require => Jboss::Util::Setgroupaccess[$jboss_home],
    }
    # $JBOSS_HOST_CONFIG = $host_config
  } else {
    # Default settings
    $host_config = ''
  }

  file { 'jboss-as-conf':
    path    => "/etc/jboss-as/jboss-as.conf",
    mode    => 755,
    content => template('jboss/jboss-as.conf.erb'),
    notify  => Service["jboss"],
    require => Setgroupaccess['set-perm'],
  }

  file { 'jbosscli':
    content => template('jboss/jboss-cli.erb'),
    mode    => 755,
    path    => '/usr/bin/jboss-cli',
    require => Setgroupaccess['set-perm'],
  }

  anchor { "jboss::installed": }
}