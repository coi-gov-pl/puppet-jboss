# Internal class that installs JBoss
class jboss::internal::package (
  $download_url     = $jboss::internal::runtime::download_url,
  $prerequisites,
  $jboss_user,
  $jboss_group,
  $product          = $jboss::params::product,
  $version          = $jboss::params::version,
  $java_autoinstall = $jboss::params::java_autoinstall,
  $java_version     = $jboss::params::java_version,
  $java_package     = $jboss::params::java_package,
  $install_dir      = $jboss::params::install_dir,
  $java_dist        = $jboss::params::java_dist,
  # Prerequisites class, that can be overwritten
) inherits jboss::params {
  include jboss
  include jboss::internal::runtime
  include jboss::internal::params
  include jboss::internal::compatibility

  $download_rootdir     = $jboss::internal::params::download_rootdir
  $download_file        = jboss_basename($download_url)
  $download_dir         = "${download_rootdir}/download-${product}-${version}"
  $home                 = $jboss::home
  $configfile           = $jboss::internal::runtime::configfile
  $standaloneconfigfile = $jboss::internal::runtime::standaloneconfigfile
  $logdir               = "${jboss::internal::params::logbasedir}/${jboss::product}"

  case $version {
    /^[0-9]+\.[0-9]+\.[0-9]+[\._-][0-9a-zA-Z_-]+$/: {
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
    path      => $jboss::internal::params::syspath,
    logoutput => 'on_failure',
  }

  if $jboss::superuser and (!defined(Group[$jboss_group])) {
    group { $jboss_group: ensure => 'present', }
  }

  if $jboss::superuser and (!defined(User[$jboss_user])) {
    $empty = ''
    create_resources('user', {
      "${jboss_user}${empty}" => {
        ensure     => 'present',
        managehome => true,
        gid        => $jboss_group,
      }
    })
  }

  $confdir = "${jboss::etcdir}/${product}"
  $rootuser = $jboss::superuser ? {
    true    => 'root',
    default => undef,
  }
  file { $confdir:
    ensure => 'directory',
    alias  => 'jboss::confdir',
    owner  => $rootuser,
    group  => $rootuser,
    mode   => '0755',
  }

  if $java_autoinstall and $jboss::superuser {
    class { 'java':
      distribution => $java_dist,
      version      => $java_version,
      package      => $java_package,
      notify       => Service[$jboss::product],
    }
    Class['java'] -> Exec['jboss::package::check-for-java']
  }

  file { [ $download_rootdir, $download_dir ]:
    ensure => 'directory',
  }

  if $download_file == undef {
    fail Puppet::Error, 'Download_url cannot be undef'
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

  if $jboss::superuser {
    jboss::internal::util::groupaccess { $jboss::home:
      user    => $jboss_user,
      group   => $jboss_group,
      require => [
        User[$jboss_user],
        Exec['jboss::test-extraction'],
      ],
      before  => [
        File['jboss::configuration-link::domain'],
        File['jboss::configuration-link::host'],
        File['jboss::configuration-link::standalone'],
        File['jboss::jbosscli'],
        Anchor['jboss::installed'],
      ],
    }
  }

  file { "${confdir}/domain.xml":
    ensure => 'link',
    alias  => 'jboss::configuration-link::domain',
    target => "${jboss::home}/domain/configuration/domain.xml",
  }
  $hostfile = 'host.xml'
  file { "${confdir}/${hostfile}":
    ensure => 'link',
    alias  => 'jboss::configuration-link::host',
    target => "${jboss::home}/domain/configuration/${hostfile}",
  }

  file { "${confdir}/standalone.xml":
    ensure => 'link',
    alias  => 'jboss::configuration-link::standalone',
    target => "${jboss::home}/standalone/configuration/${standaloneconfigfile}",
  }

  $full_initd_file = $jboss::internal::compatibility::full_initd_file
  if $jboss::superuser {
    file { $full_initd_file:
      ensure => 'link',
      alias  => 'jboss::service-link',
      target => $jboss::internal::compatibility::initd_file,
      before => Anchor['jboss::installed'],
    }
    Jboss::Internal::Util::Groupaccess[$jboss::home]
      -> File['jboss::service-link']
  } else {
    $pidfile    = "${logdir}/${jboss::product}.pid"
    file { "${jboss::bindir}/init.d":
      ensure => 'directory',
    }
    file { $full_initd_file:
      ensure  => 'file',
      mode    => '0750',
      content => template('jboss/userland/initd.sh.erb'),
      before  => Anchor['jboss::package::end'],
    }
  }

  $jbosscli_path = "${jboss::bindir}/${jboss::internal::compatibility::product_short}-cli"

  file { $jbosscli_path:
    ensure  => 'file',
    alias   => 'jboss::jbosscli',
    content => template('jboss/jboss-cli.erb'),
    mode    => '0755',
    before  => Anchor['jboss::installed'],
  }

  exec { 'jboss::package::check-for-java':
    command => 'echo "Please provide Java executable to system!" 1>&2 && exit 1',
    unless  => '[ `which java` ] && java -version 2>&1 | grep -q \'java version\'',
    require => Anchor['jboss::installed'],
    before  => Anchor['jboss::package::end'],
  }

  anchor { 'jboss::installed':
    require => [
      Exec['jboss::test-extraction'],
      File['jboss::confdir'],
      File['jboss::logfile'],
    ],
    before  => Anchor['jboss::package::end'],
  }
  anchor { 'jboss::package::end': }
}
