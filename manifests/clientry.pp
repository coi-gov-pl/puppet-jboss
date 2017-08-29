# == Define: jboss::clientry
#
# This define is very versitale. It can be used to add or remove any JBoss CLI entry. You can pass any number of properties for
# given CLI path and each one will be manage, other parameters will not be changed.
#
# === Parameters:
#
# This type uses *JBoss module standard metaparameters*
#
# [*ensure*]
#     Standard ensure parameter. Can be either `present` or `absent`.
# [*path*]
#     This is the namevar. Path of the CLI entry. This is path accepted by JBoss CLI. The path must be passed without
#     `/profile=<profile-name>` in domain mode as well (for that `profile` parameter must be used).
# [*properties*]
#     This is optional properties hash. You can pass any valid JBoss properties for given `path`. For valid ones head to the JBoss
#     Application Server documentation. Must be hash object or `undef` value.
# [*dorestart*]
#     This parameter forces to execute command `:restart()` on this CLI entry.
#
define jboss::clientry (
  $ensure      = 'present',
  $path        = $name,
  $properties  = undef,
  $profile     = '$::jboss::profile',
  $controller  = '$::jboss::controller',
  $runasdomain = $::jboss::runasdomain,
  $dorestart   = true,
) {
  include jboss
  include jboss::internal::service
  include jboss::internal::runtime::node

  case $ensure {
    'running':  {}
    'stopped':  {}
    'absent':   {}
    'present':  {}
    'enabled':  {}
    'disabled': {}
    default:   {
      fail("Invalid value for ensure: `${ensure}`. Supported values are: `present`, `absent`, `running`, `stopped`, `enabled`, `disabled`")
    }
  }

  jboss_confignode { $name:
    ensure      => $ensure,
    path        => $path,
    properties  => $properties,
    controller  => $controller,
    ctrluser    => $jboss::internal::runtime::node::username,
    ctrlpasswd  => $jboss::internal::runtime::node::password,
    profile     => $profile,
    runasdomain => $runasdomain,
    require     => Anchor['jboss::package::end'],
  }

  if str2bool($::jboss_running) {
    Jboss_confignode[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_confignode[$name]
  }

  if $dorestart {
    if !$::jboss::runasdomain {
      Jboss_confignode[$name] ~> Exec['jboss::service::restart']
    }
  }

}
