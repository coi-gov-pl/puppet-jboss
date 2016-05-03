# Internal class. Do not use it outside of internal context.
class jboss::internal::params (
  $given_download_rootdir = undef,
  $given_logbasedir       = undef,
  $given_installdir       = undef,
  $given_etcdir           = undef,
  $given_bindir           = undef,
  $usermode_basedir       = $::jboss_userhomedir,
  ) {

  $superuser = jboss_to_bool($::jboss_superuser)

  # Basically take what was given or try to figure it out, for
  # super user or regular one.
  $__default_download_rootdir = $given_download_rootdir ? {
    undef   => $superuser ? {
      true    => '/usr/src',
      default => "${usermode_basedir}/downloads",
    },
    default => $given_download_rootdir,
  }
  $__default_logbasedir = $given_logbasedir ? {
    undef   => $superuser ? {
      true    => '/var/log',
      default => "${usermode_basedir}/logs",
    },
    default => $given_logbasedir,
  }
  $__default_installdir = $given_installdir ? {
    undef   => $superuser ? {
      true    => '/usr/lib',
      default => "${usermode_basedir}/opt",
    },
    default => $given_installdir,
  }
  $__default_etcdir = $given_etcdir ? {
    undef   => $superuser ? {
      true    => '/etc',
      default => "${usermode_basedir}/etc",
    },
    default => $given_etcdir,
  }
  $__default_bindir = $given_bindir ? {
    undef   => $superuser ? {
      true    => '/usr/bin',
      default => "${usermode_basedir}/bin",
    },
    default => $given_bindir
  }
  $__default_user = $superuser ? {
    true    => 'jboss',
    default => $::id,
  }
  $__default_group = $superuser ? {
    true    => 'jboss',
    default => $::id,
  }

  # Directory to download installation temporary files
  $download_rootdir = hiera('jboss::internal::params::download_rootdir',
      $__default_download_rootdir)

  # Directory for logging
  $logbasedir = hiera('jboss::internal::params::logbasedir',
      $__default_logbasedir)

  # Directory of etc
  $etcdir = hiera('jboss::internal::params::etcdir',
      $__default_etcdir)

  # Directory for binaries
  $bindir = hiera('jboss::internal::params::bindir',
      $__default_bindir)

  include jboss::internal::params::socketbinding
  include jboss::internal::params::memorydefaults

  # Util System PATH variable to avoid mocking in tests
  $syspath = $::path ? {
    undef   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    default => $::path,
  }
}
