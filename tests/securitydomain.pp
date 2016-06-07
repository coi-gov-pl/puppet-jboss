include jboss

jboss::securitydomain { 'db-auth-default':
  ensure        => 'present',
  code          => 'asdasd',
  codeflag      => 'required',
  moduleoptions => {
    'dsJndiName'        => ':jboss/datasources/default-db',
    'principalsQuery'   => 'select \'password\' from users u where u.login = ?',
    'hashUserPassword'  => true,
    'hashStorePassword' => false,
    'rolesQuery'        => 'select r.name, \'Roles\' from users',
  },
}
