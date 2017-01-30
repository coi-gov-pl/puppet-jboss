include jboss

jboss::module { 'postgresql-jdbc':
  layer        => 'jdbc',
  artifacts    => [
    'https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar',
  ],
  dependencies => [
    'javax.transaction.api',
    'javax.api',
  ],
}