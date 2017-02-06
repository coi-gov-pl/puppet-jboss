$user = 'jb-user'
$passwd = 'SeC3eT!1'

node 'controller' {
  include jboss::domain::controller
  include jboss
  jboss::user { $user:
    ensure   => 'present',
    password => $passwd,
  }
}

node 'node' {
  class { 'jboss::domain::node':
    ctrluser     => $user,
    ctrlpassword => $passwd,
  }
  include jboss
}