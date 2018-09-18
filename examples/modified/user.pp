include jboss

jboss::user { 'admin':
  ensure   => 'present',
  password => 't0p-5seCret1!',
}
