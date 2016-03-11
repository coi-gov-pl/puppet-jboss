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
  $ensure       = 'present',
  $jndi         = $name,
  $redeploy     = false,
  $servergroups = hiera('jboss::deploy::servergroups', undef),
  $controller   = $::jboss::controller,
  $runasdomain  = $::jboss::runasdomain,
) {
  include jboss
  include jboss::internal::runtime::node

  jboss_deploy { $jndi:
    ensure       => $ensure,
    source       => $path,
    runasdomain  => $runasdomain,
    redeploy     => $redeploy,
    servergroups => $servergroups,
    controller   => $controller,
    ctrluser     => $jboss::internal::runtime::node::username,
    ctrlpasswd   => $jboss::internal::runtime::node::password,
    require      => [
      Anchor['jboss::service::end'],
      Exec['jboss::service::restart'],
    ],
  }

}
