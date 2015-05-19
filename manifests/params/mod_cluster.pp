# Parameters for mod cluster
class jboss::params::mod_cluster {
  # Version of mod_cluster
  $version = hiera('jboss::params::mod_cluster::version', '1.2.6.Final')
}