# Creates JBoss user
define jboss::user (
  $password,
  $ensure     = 'present',
  $user       = $name,
  $realm      = 'ManagementRealm',
  $roles      = undef,
) {

  include jboss
  require jboss::internal::package
  include jboss::internal::service

  $home = $jboss::home

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
  $jbossuserfix = '2>&1 | awk \'BEGIN{a=0}{if (/Error/){a=1};print}END{if (a==1) exit 1}\''

  case $ensure {
    'present': {
      $rolesstr = $roles ? {
        undef   => '',
        default => "--roles '${roles}'"
      }
      # By default the properties realm expects the entries to be in the format: -
      # username=HEX( MD5( username ':' realm ':' password))
      $mangledpasswd = md5("${name}:${realm}:${password}")
      exec { "jboss::user::add(${realm}/${name})":
        environment => [
          "JBOSS_HOME=${home}",
          "__PASSWD=${password}"
        ],
        command     => "${home}/bin/add-user.sh --silent --user '${name}' --password \"\$__PASSWD\" --realm '${realm}' ${rolesstr} ${extraarg} ${jbossuserfix}",
        unless      => "/bin/egrep -e '^${name}=${mangledpasswd}' ${filepath}",
        require     => Anchor['jboss::package::end'],
        notify      => Service[$jboss::internal::service::servicename],
        logoutput   => true,
      }
      if $application_realm {
        file_line { "jboss::user::roles::add(${realm}/${name})":
          ensure  => present,
          path    => $filepath_roles,
          line    => "${name}=${roles}",
          match   => "${name}=.*",
          require => Exec["jboss::user::add(${realm}/${name})"],
          notify  => Service[$jboss::internal::service::servicename],
        }
      }
    }
    'absent':{
      exec { "jboss::user::remove(${realm}/${name})":
        command   => "/bin/sed -iE 's/^${name}=.*$//g' ${filepath}",
        onlyif    => "/bin/egrep -e '^${name}=' ${filepath}",
        require   => Anchor['jboss::package::end'],
        logoutput => 'on_failure',
        notify    => Service[$jboss::internal::service::servicename],
      }
      if $application_realm {
        exec { "jboss::user::roles::remove(${realm}/${name})":
          command   => "/bin/sed -iE 's/^${name}=.*$//g' ${filepath_roles}",
          onlyif    => "/bin/egrep -e '^${name}=' ${filepath_roles}",
          require   => Anchor['jboss::package::end'],
          logoutput => 'on_failure',
          notify    => Service[$jboss::internal::service::servicename],
        }
      }
    }
    default: {
      fail("Ensure must be eiter present or absent, provided: `${ensure}`!")
    }
  }

}
