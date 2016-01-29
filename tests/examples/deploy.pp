include jboss

jboss::deploy { 'foobar-app':
  ensure      => 'present',
  servergroup => 'foobar-group',
  path        => '/usr/src/foobar-app-1.0.0.war',
}