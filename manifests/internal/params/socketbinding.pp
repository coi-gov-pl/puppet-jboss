# Internal class - socketbinging params
class jboss::internal::params::socketbinding {
  # Default sockets to be used, if not passed to `jboss::domain::server` or `jboss::domain::servergroup`
  $group       = hiera('jboss::internal::params::socketbinding::group', 'full-sockets')

  # Default offset for server ports to be used, if not passed to `jboss::domain::server` or `jboss::domain::servergroup`
  $port_offset = hiera('jboss::internal::params::socketbinding::port_offset', 0)
}
