# == Define: jboss::securitydomain
#
# This defined type can be used to add and remove JBoss security domains. A security domain 
# consists of configurations for authentication, authorization, security mapping, and auditing. 
# It implements Java Authentication and Authorization Service (JAAS) declarative security.
# 
# See here: https://access.redhat.com/documentation/en-US/JBoss_Enterprise_Application_Platform/6.4/html/Security_Guide/sect-Security_Domains.html
#
# === Parameters
#
# This type uses *JBoss module standard metaparameters*
#
# [*name*]
#     **This is the namevar**. The name/ID of security domain.
# [*ensure*]
#     Standard Puppet ensure parameter with values: 'present' and 'absent'
# [*code*]
#     The code for JBoss security domain
# [*codeflag*]
#     The code flag for JBoss security domain
# [*moduleoptions*]
#     Options for given Login module if form of a Puppet hash table
#
define jboss::securitydomain (
  $ensure        = 'present',
  $code          = undef,
  $codeflag      = undef,
  $moduleoptions = undef,
  $profile       = $jboss::profile,
  $controller    = $jboss::controller,
  $runasdomain   = $jboss::runasdomain,
) {
  include jboss
  include jboss::internal::service
  include jboss::internal::runtime::node

  jboss_securitydomain { $name:
    ensure        => $ensure,
    code          => $code,
    codeflag      => $codeflag,
    moduleoptions => $moduleoptions,
    runasdomain   => $runasdomain,
    profile       => $profile,
    controller    => $controller,
    ctrluser      => $jboss::internal::runtime::node::username,
    ctrlpasswd    => $jboss::internal::runtime::node::password,
    require       => Anchor['jboss::package::end'],
  }

  if jboss_to_bool($::jboss_running) {
    Jboss_securitydomain[$name] ~> Service[$jboss::internal::service::servicename]
  } else {
    Anchor['jboss::service::end'] -> Jboss_securitydomain[$name] ~> Exec['jboss::service::restart']
  }
}
