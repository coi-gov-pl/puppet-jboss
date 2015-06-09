# Class ensure that JBoss runs as a domain node
class jboss::domain::node (
  $ctrluser,
  $ctrlpassword,
) {
  class { 'jboss::internal::runtime::node':
    username => $ctrluser,
    password => $ctrlpassword,
  }
}
