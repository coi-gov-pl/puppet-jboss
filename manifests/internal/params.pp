class jboss::internal::params {

  # Directory to download installation temporary files
  $download_rootdir = hiera('jboss::internal::params::download_rootdir', '/usr/src')

  # Directory for logging
  $logbasedir = hiera('jboss::internal::params::logbasedir', '/var/log')

  include jboss::internal::params::socketbinding
  include jboss::internal::params::memorydefaults
}
