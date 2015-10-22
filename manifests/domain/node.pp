# == Class: jboss::domain::node
#
# This class will setup JBoss server to run as node of the domain. 
#
# It takes two parameters: `ctrluser` and `ctrlpassword`. User name and password must 
# be setup to JBoss controller. Easiest way to add jboss management user 
# with `jboss::user` type.
#
# Example:
#
#   $user = 'jb-user'
#   $passwd = 'SeC3eT!1'
#   node 'controller' {
#     include jboss::domain::controller
#     include jboss
#     jboss::user { $user:
#       ensure   => 'present',
#       password => $passwd,
#     }
#   }
#   node 'node' {
#     class { 'jboss::domain::node':
#       ctrluser     => $user,
#       ctrlpassword => $passwd,
#     }
#   }
#
class jboss::domain::node (
  $ctrluser,
  $ctrlpassword,
) {
  class { 'jboss::internal::runtime::node':
    username => $ctrluser,
    password => $ctrlpassword,
  }
}
