# == Define: jboss::deploy
#
# This defined type can be used to deploy and undeploy standard Java artifacts to JBoss server
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*path*]
#     A path to standard Java archive for ex.: war or ear file.
# [*ensure*]
#     Standard ensure parameter. Can be either present or absent.
# [*jndi*]
#     **This is the namevar**. The JNDI name of deployed archive.
# [*redeploy*]
#     This parameter can be used to force redeployment of already deployed archive. By default it
#     is equals for false
# [*servergroups*]
#     In domain mode, you need to pass here actual server group name on which you wish to deploy
#     the archive.
#
define jboss::deploy (
  $path,
  $ensure              = 'present',
  $jndi                = $name,
  $redeploy_on_refresh = false,
  $servergroups        = hiera('jboss::deploy::servergroups', undef),
  $controller          = $::jboss::controller,
  $runasdomain         = $::jboss::runasdomain,
  $runtime_name        = undef,
) {
  include jboss
  include jboss::internal::runtime::node

  if $runtime_name != undef {
    validate_re($runtime_name, '.+(\.ear|\.zip|\.war|\.jar)$', 'Invalid file extension, module only supports: .jar, .war, .ear, .rar')
  }

  jboss_deploy { $jndi:
    ensure              => $ensure,
    source              => $path,
    runasdomain         => $runasdomain,
    redeploy_on_refresh => $redeploy_on_refresh,
    servergroups        => $servergroups,
    controller          => $controller,
    ctrluser            => $jboss::internal::runtime::node::username,
    ctrlpasswd          => $jboss::internal::runtime::node::password,
    runtime_name        => $runtime_name,
    require             => [
      Anchor['jboss::end'],
      Exec['jboss::service::restart'],
    ],
  }

}
