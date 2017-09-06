# Internal define - foreach for servergroup
define jboss::internal::domain::servergroup::foreach (
  $group,
  $profile,
  $controller,
  $ensure     = 'present',
  $key        = $name,
  $map        = {},
) {

  #Remove group prefix from system property name
  $split = split($key, '~~~')
  $property = $split[1]

  $value = $map[$property]

  jboss::clientry { "jboss::domain::servergroup::sysproperty(${key} => ${value})":
    ensure      => $ensure,
    path        => "/server-group=${group}/system-property=${property}",
    profile     => $profile,
    controller  => $controller,
    runasdomain => true,
    properties  => {
      value => $value,
    }
  }

  if $ensure == 'present' {
    JBoss::Clientry["jboss::domain::servergroup(${group})"] -> JBoss::Clientry["jboss::domain::servergroup::sysproperty(${key} => ${value})"]
  } else {
    JBoss::Clientry["jboss::domain::servergroup::sysproperty(${key} => ${value})"] -> JBoss::Clientry["jboss::domain::servergroup(${group})"]
  }
}
