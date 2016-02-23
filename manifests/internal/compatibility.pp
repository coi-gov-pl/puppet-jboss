# Internal class - handles compatibility between
class jboss::internal::compatibility {
  include jboss

  case $jboss::product {
    'wildfly': {
      if versioncmp($jboss::version, '8.0.0') < 0 or versioncmp($jboss::version, '10.0.0') >= 0 {
        fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: Wildfly 8.x and 9.x series")
      }
    }
    'jboss-eap': {
      if versioncmp($jboss::version, '6.0.0') < 0 or versioncmp($jboss::version, '8.0.0') >= 0 {
        fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: JBoss EAP 6.x and 7.x series")
      }
    }
    'jboss-as': {
      if versioncmp($jboss::version, '7.0.0') < 0 or versioncmp($jboss::version, '8.0.0') >= 0 {
        fail("Unsupported version ${jboss::product} ${jboss::version}. Supporting only: JBoss AS 7.x series")
      }
    }
    default: {
      fail("Unsupported product ${jboss::product}. Supporting only: 'jboss-eap', 'jboss-as' and 'wildfly'")
    }
  }

  case $jboss::product {
    'wildfly': {
      $controller_port = '9990'
      $__osfamily_down = downcase($::osfamily)
      $initd_file      = "${jboss::home}/bin/init.d/wildfly-init-${__osfamily_down}.sh"
      $product_short   = 'wildfly'
    }
    'jboss-eap', 'jboss-as': {
      $controller_port = '9999'
      $product_short   = 'jboss'
      $initd_file      = $jboss::runasdomain ? {
        true    => "${jboss::home}/bin/init.d/jboss-as-domain.sh",
        default => "${jboss::home}/bin/init.d/jboss-as-standalone.sh",
      }
    }
    default: {}
  }

}
