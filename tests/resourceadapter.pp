include jboss

jboss::deploy { 'jca-filestore.rar':
  path => '/usr/src/jca-filestore.rar',
}

jboss::resourceadapter { 'jca-filestore.rar':
  archive            => 'jca-filestore.rar',
  transactionsupport => 'LocalTransaction',
  classname          => 'org.example.jca.FileSystemConnectionFactory',
  jndiname           => 'java:/jboss/jca/photos',
  require            => JBoss::Deploy['jca-filestore.rar'],
}