class jboss::internal::params {

  $__default_download_rootdir = jboss_to_bool($::jboss_superuser) ? {
    true    => '/usr/src',
    default => "${::jboss_userhomedir}/downloads",
  }
  $__default_logbasedir = jboss_to_bool($::jboss_superuser) ? {
    true    => '/var/log',
    default => "${::jboss_userhomedir}/logs",
  }
  $__default_installdir = jboss_to_bool($::jboss_superuser) ? {
    true    => '/usr/lib',
    default => "${::jboss_userhomedir}/opt",
  }

  # Directory to download installation temporary files
  $download_rootdir = hiera('jboss::internal::params::download_rootdir', $__default_download_rootdir)

  # Directory for logging
  $logbasedir = hiera('jboss::internal::params::logbasedir', $__default_logbasedir)

  include jboss::internal::params::socketbinding
  include jboss::internal::params::memorydefaults

  # Util System PATH variable to avoid mocking in tests
  $syspath = $::path ? {
    undef   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    default => $::path,
  }
}
