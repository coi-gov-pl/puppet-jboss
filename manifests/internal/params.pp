class jboss::internal::params {
  
  # Directory to download installation temporary files
  $download_rootdir = hiera('jboss::internal::params::download_rootdir', '/usr/src')
  
  #Directory for logging
  $logdir = hiera('jboss::internal::params::logdir', '/var/log/jboss-as')
  
  # File for logging
  $logfile = hiera('jboss::internal::params::logfile', "${logdir}/console.log")
  
  
  class socketbinding {
    # Default sockets to be used, if not passed to `jboss::domain::server` or `jboss::domain::servergroup`
    $group       = hiera('jboss::internal::params::socketbinding::group', 'full-sockets')
    
    # Default offset for server ports to be used, if not passed to `jboss::domain::server` or `jboss::domain::servergroup`
    $port_offset = hiera('jboss::internal::params::socketbinding::port_offset', 0)
  } 
  include socketbinding
  
  # JBoss memory defaults
  class memorydefaults {
    # Perm Gen memory initial
    $permgensize    = hiera('jboss::internal::params::memorydefaults::permgensize', '32m')
    # Perm Gen memory maximum
    $maxpermgensize = hiera('jboss::internal::params::memorydefaults::maxpermgensize', '256m')
    # Heap memory initial
    $heapsize       = hiera('jboss::internal::params::memorydefaults::heapsize', '256m')
    # Heap memory maximum
    $maxheapsize    = hiera('jboss::internal::params::memorydefaults::maxheapsize', '1303m')
  }
  include memorydefaults
}
