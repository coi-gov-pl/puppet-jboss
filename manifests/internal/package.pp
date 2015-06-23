# Internal class that installs JBoss
class jboss::internal::package (
  $download_url,
  $prerequisites,
  $jboss_user       = $jboss::params::jboss_user,
  $jboss_group      = $jboss::params::jboss_group,
  $product          = $jboss::params::product,
  $version          = $jboss::params::version,
  $java_autoinstall = $jboss::params::java_autoinstall,
  $java_version     = $jboss::params::java_version,
  $java_package     = $jboss::params::java_package,
  $install_dir      = $jboss::params::install_dir,
  # Prerequisites class, that can be overwritten
) inherits jboss::params {
  include jboss
  include jboss::internal::runtime

  $download_rootdir = $jboss::internal::params::download_rootdir
  $download_file    = jboss_basename($download_url)
  $download_dir     = "${download_rootdir}/download-${product}-${version}"

  $home             = $jboss::home

  $logdir     = $jboss::internal::params::logdir
  $logfile    = $jboss::internal::params::logfile
  $configfile = $jboss::internal::runtime::configfile

  case $version {
    /^(?:(?:eap|as)-)?[0-9]+\.[0-9]+\.[0-9]+[\._-][0-9a-zA-Z_-]+$/: {
      debug("Running in version: ${1} -> ${version}")
    }
    default: {
      fail("Invalid Jboss version passed: `${version}`! Pass valid version for ex.: `6.2.0.GA`")
    }
  }

  anchor { 'jboss::package::begin':
    require => Anchor['jboss::begin'],
  }

  File {
    owner => $jboss_user,
    group => $jboss_group,
    mode  => '2750',
  }

  Exec {
    path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
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

  $confdir = "/etc/${product}"

  file { $confdir:
    ensure => 'directory',
    alias  => 'jboss::confdir',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $logdir:
    ensure => 'directory',
    alias  => 'jboss::logdir',
    owner  => 'root',
    group  => $jboss_group,
    mode   => '2770',
  }

  file { $logfile:
    ensure => 'file',
    alias  => 'jboss::logfile',
    owner  => 'root',
    group  => $jboss_group,
    mode   => '0660',
  }

  if $java_autoinstall {
    class { 'java':
      distribution => 'jdk',
      version      => $java_version,
      package      => $java_package,
      notify       => Service[$jboss::product],
    }
    Class['java'] -> Exec['jboss::package::check-for-java']
  }

  file { $download_dir:
    ensure => 'directory',
  }

  jboss::internal::util::fetch::file { $download_file:
    address   => $download_url,
    fetch_dir => $download_dir,
    require   => File[$download_dir],
  }

  if $prerequisites == Class['jboss::internal::prerequisites'] {
    include jboss::internal::prerequisites
  }

  exec { 'jboss::unzip-downloaded':
    command => "unzip -o -q ${download_dir}/${download_file} -d ${jboss::home}",
    cwd     => $download_dir,
    creates => $jboss::home,
    require => [
      $prerequisites, # Prerequisites class, that can be overwritten
      Jboss::Internal::Util::Fetch::File[$download_file],
      Package['unzip'],
    ],
  }

  exec { 'jboss::move-unzipped':
    command => "mv ${jboss::home}/*/* ${jboss::home}/",
    creates => "${jboss::home}/bin",
    require => Exec['jboss::unzip-downloaded'],
  }

  exec { 'jboss::test-extraction':
    command => "echo '${jboss::home}/bin/init.d not found!' 1>&2 && exit 1",
    unless  => "test -d ${jboss::home}/bin/init.d",
    require => Exec['jboss::move-unzipped'],
  }

  jboss::internal::util::groupaccess { $jboss::home:
    user    => $jboss_user,
    group   => $jboss_group,
    require => [
      User[$jboss_user],
      Exec['jboss::test-extraction'],
    ],
  }

  file { '/etc/init.d/jboss-domain':
    ensure  => 'link',
    alias   => 'jboss::service-link::domain',
    target  => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
    require => Jboss::Internal::Util::Groupaccess[$jboss::home],
  }

  file { '/etc/init.d/jboss-standalone':
    ensure  => 'link',
    alias   => 'jboss::service-link::standalone',
    target  => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
    require => Jboss::Internal::Util::Groupaccess[$jboss::home],
  }

  file { "${confdir}/domain.xml":
    ensure  => 'link',
    alias   => 'jboss::configuration-link::domain',
    target  => "${jboss::home}/domain/configuration/domain.xml",
    require => Jboss::Internal::Util::Groupaccess[$jboss::home],
  }
  $hostfile = 'host.xml'
  file { "${confdir}/${hostfile}":
    ensure  => 'link',
    alias   => 'jboss::configuration-link::host',
    target  => "${jboss::home}/domain/configuration/${hostfile}",
    require => Jboss::Internal::Util::Groupaccess[$jboss::home],
  }

  file { "${confdir}/standalone.xml":
    ensure  => 'link',
    alias   => 'jboss::configuration-link::standalone',
    target  => "${jboss::home}/standalone/configuration/${configfile}",
    require => Jboss::Internal::Util::Groupaccess[$jboss::home],
  }

  $target = $jboss::runasdomain ? {
    true    => '/etc/init.d/jboss-domain',
    default => '/etc/init.d/jboss-standalone',
  }

  file { "/etc/init.d/${product}":
    ensure  => 'link',
    alias   => 'jboss::service-link',
    target  => $target,
    require => Jboss::Internal::Util::Groupaccess[$jboss::home],
    notify  => [
      Exec['jboss::kill-existing::domain'],
      Exec['jboss::kill-existing::standalone'],
    ],
  }

  exec { 'jboss::kill-existing::domain':
    command     => '/etc/init.d/jboss-domain stop',
    refreshonly => true,
    onlyif      => '/etc/init.d/jboss-domain status',
    before      => Service[$product],
  }

  exec { 'jboss::kill-existing::standalone':
    command     => '/etc/init.d/jboss-standalone stop',
    refreshonly => true,
    onlyif      => '/etc/init.d/jboss-standalone status',
    before      => Service[$product],
  }

  file { '/usr/bin/jboss-cli':
    ensure  => 'file',
    alias   => 'jboss::jbosscli',
    content => template('jboss/jboss-cli.erb'),
    mode    => '0755',
    require => Jboss::Internal::Util::Groupaccess[$jboss::home],
  }

  exec { 'jboss::package::check-for-java':
    command => 'echo "Please provide Java executable to system!" 1>&2 && exit 1',
    unless  => '[ `which java` ] && java -version 2>&1 | grep -q \'java version\'',
    require => Anchor['jboss::installed'],
    before  => Anchor['jboss::package::end'],
  }

  anchor { 'jboss::installed':
    require => [
      Jboss::Internal::Util::Groupaccess[$jboss::home],
      Exec['jboss::test-extraction'],
      File['jboss::confdir'],
      File['jboss::logfile'],
      File['jboss::jbosscli'],
      File['jboss::service-link'],
    ],
    before  => Anchor['jboss::package::end'],
  }
  anchor { 'jboss::package::end': }
}
