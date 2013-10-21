define jboss::user (
  $user = $name, 
  $realm = 'ManagementRealm', 
  $password, 
  $jboss_home = undef, # Deprecated, it is not needed, will be removed
) {
  
  include jboss
  
  $home = $jboss_home ? { # Deprecated, it is not needed, will be removed
    undef   => $jboss::home,
    default => $jboss_home,
  }
  
  case $realm {
    'ManagementRealm'  : {
      exec { "add jboss user ${name}/${realm}":
        environment => ["JBOSS_HOME=${home}",],
        command     => "${home}/bin/add-user.sh -u ${name} -p ${password} -s",
        unless      => "/bin/egrep -e '^${name}=' ${home}/domain/configuration/mgmt-users.properties",
        logoutput   => 'on_failure',
      }
    }
    'ApplicationRealm' : {
      exec { "add jboss user ${name}/${realm}":
        environment => ["JBOSS_HOME=${home}",],
        command     => "${home}/bin/add-user.sh -u ${name} -p ${password} -s -a",
        unless      => "/bin/egrep -e '^${name}=' ${home}/domain/configuration/application-users.properties",
        logoutput   => 'on_failure',
      }
    }
    default            : {
      fail("Unknown realm ${realm} for jboss::user")
    }
  }
}