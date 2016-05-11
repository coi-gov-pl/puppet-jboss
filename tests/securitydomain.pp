include jboss

jboss::securitydomain { 'db-auth-default':
  ensure        => 'absent',
  code          => 'asdasd',
  codeflag      => 'required',
  moduleoptions => {
    'dsJndiName'        => ':jboss/datasources/default-db',
    'principalsQuery'   => 'select \'password\' from users u where u.login = ?',
    'hashUserPassword'  => true,
    'hashStorePassword' => false,
    'rolesQuery'        => 'select r.name, \'Roles\' from users u
join user_roles ur on ur.user_id = u.id
join roles r on r.id = ur.role_id
where u.login = ?',
  },
}
