define jboss::user (
  $user = $name, 
  $realm = 'ManagementRealm', 
  $jboss_home,
  $password, 
) {
  case $realm {
    'ManagementRealm'  : {
      exec { "add jboss user ${name}/${realm}":
        environment => ["JBOSS_HOME=${jboss_home}",],
        command     => "${jboss_home}/bin/add-user.sh -u ${name} -p ${password} -s",
        unless      => "/bin/egrep -e '^${name}=' ${jboss_home}/domain/configuration/mgmt-users.properties",
        logoutput   => 'on_failure',
      }
    }
    'ApplicationRealm' : {
      exec { "add jboss user ${name}/${realm}":
        environment => ["JBOSS_HOME=${jboss_home}",],
        command     => "${jboss_home}/bin/add-user.sh -u ${name} -p ${password} -s -a",
        unless      => "/bin/egrep -e '^${name}=' ${jboss_home}/domain/configuration/application-users.properties",
        logoutput   => 'on_failure',
      }
    }
    default            : {
      fail("Unknown realm ${realm} for jboss::user")
    }
  }
}