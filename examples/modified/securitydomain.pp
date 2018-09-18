include jboss

jboss::securitydomain { 'db-auth-default':
  ensure        => 'present',
  code          => 'Database',
  codeflag      => 'required',
  moduleoptions => {
    'dsJndiName'        => 'java:jboss/datasources/x-default-db',
    'principalsQuery'   => 'select \'password\' from user u where u.login = ?',
    'hashUserPassword'  => true,
    'hashStorePassword' => false,
    'rolesQuery'        => 'select r.name, \'roles\' from users',
  },
}
