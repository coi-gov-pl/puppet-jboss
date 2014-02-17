define jboss::user (
  $user       = $name,
  $ensure     = 'present',
  $realm      = 'ManagementRealm', 
  $password, 
  $jboss_home = undef, # Deprecated, it is not needed, will be removed
) {
  
  include jboss
  
  $home = $jboss_home ? { # Deprecated, it is not needed, will be removed
    undef   => $jboss::home,
    default => $jboss_home,
  }
  
  $dir = $jboss::runasdomain ? {
    true    => 'domain',
    default => 'standalone',
  }
  
  $file = $realm ? {
    'ManagementRealm'  => 'mgmt-users.properties',
    'ApplicationRealm' => 'application-users.properties',
    default            => undef,
  }

  # -a is needed to set in application-users.properties file
  $extraarg = $realm ? {
    'ApplicationRealm' => '-a',
    default            => '',
  }

  
  if $file == undef {
    fail("Unknown realm `${realm}` for jboss::user")
  }
  
  $filepath = "${home}/${dir}/configuration/${file}"
  
  case $ensure {
    'present': {
      exec { "jboss::user::add(${realm}/${name})":
        alias       => "add jboss user ${name}/${realm}", # Deprecated, it is not needed, will be removed
        environment => ["JBOSS_HOME=${home}",],
        command     => "${home}/bin/add-user.sh -u '${name}' -p '${password}' -r '${realm}' ${extraarg} -s",
        unless      => "/bin/egrep -e '^${name}=' ${filepath}",
        require     => Anchor['jboss::package::end'],
        logoutput   => 'on_failure',
      }
    }
    'absent':{
      exec { "jboss::user::remove(${realm}/${name})":
        command     => "/bin/sed -iE 's/^${name}=.*$//g' ${filepath}",
        onlyif      => "/bin/egrep -e '^${name}=' ${filepath}",
        require     => Anchor['jboss::package::end'],
        logoutput   => 'on_failure',
      }
    }
    default: {
      fail("Ensure must be eiter present or absent, provided: `${ensure}`!")
    }
  }
  
}
