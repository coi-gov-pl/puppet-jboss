class jboss::package (
  $jboss_user       = $jboss::params::jboss_user,
  $jboss_group      = $jboss::params::jboss_group,
  $download_url     = $jboss::params::download_url,
  $version          = $jboss::params::version,
  $java_autoinstall = $jboss::params::java_autoinstall,
  $java_version     = $jboss::params::java_version,
  $java_package     = $jboss::params::java_package,
  $install_dir      = $jboss::params::install_dir,
) inherits jboss::params {
  include jboss
  
  $download_rootdir = $jboss::params::internal::download_rootdir
  $download_file = jboss_basename($download_url)
  $download_dir  = "$download_rootdir/download-jboss-${version}"
  $home = $jboss::home
  
  $logdir  = $jboss::params::internal::logdir
  $logfile = $jboss::params::internal::logfile
  
  case $version {
    /^(?:eap|as)-[0-9]+\.[0-9]+\.[0-9]+[\._-][0-9a-zA-Z_-]+$/: {
      debug("Running in version: $1 -> $version")
    }
    default: {
      fail("Invalid Jboss version passed: `$version`! Pass valid version for ex.: `eap-6.1.0.GA`")
    }
  }

  anchor { "jboss::package::begin":
    require => Anchor['jboss::begin'],
  }

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

  file { 'jboss::confdir':
    path   => '/etc/jboss-as',
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '755',
  }
  
  file { 'jboss::logdir':
    path   => $logdir,
    ensure => 'directory',
    owner  => 'root',
    group  => $jboss_group,
    mode   => '2770',
  }
  
  file { 'jboss::logfile':
    path   => $logfile,
    ensure => 'file',
    owner  => 'root',
    group  => $jboss_group,
    mode   => '0660',
  }
  
  if $java_autoinstall {
    class { 'java':
      distribution => 'jdk',
      version      => $java_version,
      package      => $java_package,
    }
    Class['java'] -> Exec['jboss::package::check-for-java']
  }

  file { $download_dir:
    ensure => 'directory', 
  }

  jboss::util::download { "${download_dir}/${download_file}":
    uri     => $download_url,
    require => File[$download_dir],
  }
  
  if ! defined(Package['unzip']) {
    package { "unzip": ensure => "latest" }
  }

  exec { 'jboss::unzip-downloaded':
    command => "unzip -o -q ${download_dir}/${download_file} -d ${download_dir}",
    cwd     => $download_dir,
    creates => $jboss::home,
    require => [
      Jboss::Util::Download["${download_dir}/${download_file}"], 
      File[$download_dir], 
      Package['unzip'],
    ],
  }

  exec { 'jboss::move-unzipped':
    cwd     => $download_dir,
    command => "mv $(unzip -l ${download_file} | head -n 4 | tail -n 1 | awk '{print \$4}') ${jboss::home}",
    creates => $jboss::home,
    require => Exec['jboss::unzip-downloaded'],
  }

  exec { 'jboss::test-extraction':
    command => "echo '${jboss::home}/bin/init.d not found!' 1>&2 && exit 1",
    unless  => "test -d ${jboss::home}/bin/init.d",
    require => Exec['jboss::move-unzipped'],
  }

  jboss::util::groupaccess { $jboss::home:
    user    => $jboss_user,
    group   => $jboss_group,
    require => [
      User[$jboss_user], 
      Exec['jboss::test-extraction'],
    ],
  }

  file { 'jboss::service-link::domain':
    ensure  => 'link',
    path    => '/etc/init.d/jboss-domain',
    target  => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
    require => Jboss::Util::Groupaccess[$jboss::home],
  }
  
  file { 'jboss::service-link::standalone':
    ensure  => 'link',
    path    => '/etc/init.d/jboss-standalone',
    target  => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
    require => Jboss::Util::Groupaccess[$jboss::home],
  }
  
  file { 'jboss::configuration-link::domain':
    ensure  => 'link',
    path    => '/etc/jboss-as/domain.xml',
    target  => "${jboss::home}/domain/configuration/domain.xml",
    require => Jboss::Util::Groupaccess[$jboss::home],
  }
  
  file { 'jboss::configuration-link::standalone':
    ensure  => 'link',
    path    => '/etc/jboss-as/standalone.xml',
    target  => "${jboss::home}/standalone/configuration/standalone.xml",
    require => Jboss::Util::Groupaccess[$jboss::home],
  }
  
  file { 'jboss::service-link':
    ensure  => 'link',
    path    => '/etc/init.d/jboss',
    target  => '/etc/init.d/jboss-domain',
    require => Jboss::Util::Groupaccess[$jboss::home],
  }
  
  file { 'jboss::jbosscli':
    content => template('jboss/jboss-cli.erb'),
    mode    => 755,
    path    => '/usr/bin/jboss-cli',
    require => Jboss::Util::Groupaccess[$jboss::home],
  }
  
  exec { 'jboss::package::check-for-java':
    command => 'echo "Please provide Java executable to system!" 1>&2 && exit 1',
    unless  => "[ `which java` ] && java -version 2>&1 | grep -q 'java version'",
    require => Anchor["jboss::installed"],
    before  => Anchor["jboss::package::end"],
  }

  anchor { "jboss::installed":
    require => [
      Jboss::Util::Groupaccess[$jboss::home],
      Exec['jboss::test-extraction'],
      File['jboss::confdir'],
      File['jboss::logfile'],
      File['jboss::jbosscli'],
      File['jboss::service-link'],
    ],
    before  => Anchor["jboss::package::end"], 
  }
  anchor { "jboss::package::end": }
}