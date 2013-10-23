class jboss::params::internal {
  
  # Directory to download installation temporary files
  $download_rootdir = hiera('jboss::params::internal::download_rootdir', '/usr/src')
  
  #Directory for logging
  $logdir = hiera('jboss::params::internal::logdir', '/var/log/jboss-as')
  
  # File for logging
  $logfile = hiera('jboss::params::internal::logfile', "${logdir}/console.log")
}
