# == Define: jboss::user
#
# This define to add and remove JBoss management and application users, manage their passwords and roles.
#
# === Parameters:
#
# [*password*]
#     **Required parameter.** This is password that will be used for user.
# [*ensure*]
#     Standard ensure parameter. Can be either `present` or `absent`.
# [*user*]
#     (namevar) Name of user to manage.
# [*realm*]
#     This is by default equal to `ManagementRealm`. It can be equal also to `ApplicationRealm`.
# [*roles*]
#     This is by default equal to `undef`. You can pass a list of roles in form of string delimited by `,` sign.
#
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
  include jboss::internal::params
  include jboss::internal::relationship::module_user

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
  Exec {
    path => $jboss::internal::params::syspath,
  }

  case $ensure {
    'present': {
      $rolesstr = $roles ? {
        undef   => '',
        default => "--roles '${roles}'"
      }
      # By default the properties realm expects the entries to be in the format: -
      # username=HEX( MD5( username ':' realm ':' password))
      $mangledpasswd = md5("${name}:${realm}:${password}")
      $command_1 = "${home}/bin/add-user.sh --silent --user '${name}' --password \"\$__PASSWD\""
      $command_2 = " --realm '${realm}' ${rolesstr} ${extraarg} ${jbossuserfix}"
      exec { "jboss::user::add(${realm}/${name})":
        environment => [
          "JBOSS_HOME=${home}",
          "__PASSWD=${password}"
        ],
        command     => "${command_1}${command_2}",
        unless      => "/bin/egrep -e '^${name}=${mangledpasswd}' ${filepath}",
        require     => [
          Anchor['jboss::package::end'],
          Anchor['jboss::internal::relationship::module_user'],
        ],
        notify      => Service[$jboss::internal::service::servicename],
        logoutput   => true,
      }
      if $application_realm {
        file_line { "jboss::user::roles::add(${realm}/${name})":
          ensure  => present,
          path    => $filepath_roles,
          line    => "${name}=${roles}",
          match   => "${name}=.*",
          require => [
            Exec["jboss::user::add(${realm}/${name})"],
            Anchor['jboss::internal::relationship::module_user'],
          ],
          notify  => Service[$jboss::internal::service::servicename],
        }
      }
    }
    'absent':{
      exec { "jboss::user::remove(${realm}/${name})":
        command   => "/bin/sed -iE 's/^${name}=.*$//g' ${filepath}",
        onlyif    => "/bin/egrep -e '^${name}=' ${filepath}",
        require   => [
          Anchor['jboss::package::end'],
          Anchor['jboss::internal::relationship::module_user'],
        ],
        logoutput => 'on_failure',
        notify    => Service[$jboss::internal::service::servicename],
      }
      if $application_realm {
        exec { "jboss::user::roles::remove(${realm}/${name})":
          command   => "/bin/sed -iE 's/^${name}=.*$//g' ${filepath_roles}",
          onlyif    => "/bin/egrep -e '^${name}=' ${filepath_roles}",
          require   => [
            Anchor['jboss::package::end'],
            Anchor['jboss::internal::relationship::module_user'],
          ],
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
