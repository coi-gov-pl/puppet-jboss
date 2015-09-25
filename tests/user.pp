include jboss

jboss::user { 'admin':
  ensure   => 'present',
  password => 'seCret1!',
}
