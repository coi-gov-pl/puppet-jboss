class jboss::params::internal {
  
  # Directory to download installation temporary files
  $download_rootdir = hiera('jboss::params::internal::download_rootdir', '/usr/src')
}
