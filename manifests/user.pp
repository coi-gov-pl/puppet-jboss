define jboss::user (
  $user       = $name,
  $ensure     = 'present',
  $realm      = 'ManagementRealm', 
  $password,
  $roles      = undef,
  $jboss_home = undef, # Deprecated, it is not needed, will be removed
) {
  
  include jboss
  include jboss::internal::service
  
  $home = $jboss_home ? { # Deprecated, it is not needed, will be removed
    undef   => $jboss::home,
    default => $jboss_home,
  }
  
  $dir = $jboss::runasdomain ? {
    true    => 'domain',
    default => 'standalone',
  }
  
  # application realm or normal
  $application_realm = $realm ? {
    'ApplicationRealm' => true,
    default            => false,
  }

  # -a is needed to set in application-users.properties file
  if ($application_realm) {
    $extraarg = '-a'
  }
  
  $file = $application_realm ? {
    true    => 'application-users.properties',
    default => 'mgmt-users.properties',
  }
  
  $filepath = "${home}/${dir}/configuration/${file}"
  $filepath_roles = "${home}/${dir}/configuration/application-roles.properties"
  
  case $ensure {
    'present': {
      exec { "jboss::user::add(${realm}/${name})":
        alias       => "add jboss user ${name}/${realm}", # Deprecated, it is not needed, will be removed
        environment => ["JBOSS_HOME=${home}",],
        command     => "${home}/bin/add-user.sh --silent --user '${name}' --password '${password}' --realm '${realm}' --roles '${roles}' ${extraarg}",
        unless      => "/bin/egrep -e '^${name}=' ${filepath}",
        require     => Anchor['jboss::package::end'],
        notify      => Service[$jboss::internal::service::servicename],
        logoutput   => 'on_failure',
      }
      if $application_realm {
        file_line { "jboss::user::roles::add(${realm}/${name})":
          ensure    => present,
          path      => $filepath_roles,
          line      => "${name}=${roles}",
          match     => "${name}=.*",
          require   => Exec["jboss::user::add(${realm}/${name})"],
          notify      => Service[$jboss::internal::service::servicename],
        }
      }
    }
    'absent':{
      exec { "jboss::user::remove(${realm}/${name})":
        command     => "/bin/sed -iE 's/^${name}=.*$//g' ${filepath}",
        onlyif      => "/bin/egrep -e '^${name}=' ${filepath}",
        require     => Anchor['jboss::package::end'],
        logoutput   => 'on_failure',
        notify      => Service[$jboss::internal::service::servicename],
      }
      if $application_realm {
        exec { "jboss::user::roles::remove(${realm}/${name})":
          command     => "/bin/sed -iE 's/^${name}=.*$//g' ${filepath_roles}",
          onlyif      => "/bin/egrep -e '^${name}=' ${filepath_roles}",
          require     => Anchor['jboss::package::end'],
          logoutput   => 'on_failure',
          notify      => Service[$jboss::internal::service::servicename],
        }
      }
    }
    default: {
      fail("Ensure must be eiter present or absent, provided: `${ensure}`!")
    }
  }
  
}
