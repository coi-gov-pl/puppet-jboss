# Internal class - handles compatibility between
class jboss::internal::compatibility {
  include jboss

  if $::osfamily != 'RedHat' and $::osfamily != 'Debian' {
    fail("Unsupported OS family: ${::osfamily}. Supporting only RHEL and Debian systems. Consult README file.")
  }

  case $jboss::product {
    'wildfly': {
      include jboss::internal::compatibility::wildfly

      $controller_port  = $jboss::internal::compatibility::wildfly::controller_port
      $product_short    = $jboss::internal::compatibility::wildfly::product_short
      $initd_file       = $jboss::internal::compatibility::wildfly::initd_file
      $systemd_file     = $jboss::internal::compatibility::wildfly::systemd_file
      $systemd_launcher = $jboss::internal::compatibility::wildfly::systemd_launcher
      $initsystem       = $jboss::internal::compatibility::wildfly::initsystem
    }
    'jboss-eap': {
      include jboss::internal::compatibility::eap

      $controller_port  = $jboss::internal::compatibility::eap::controller_port
      $product_short    = $jboss::internal::compatibility::eap::product_short
      $initd_file       = $jboss::internal::compatibility::eap::initd_file
      $systemd_file     = $jboss::internal::compatibility::eap::systemd_file
      $systemd_launcher = $jboss::internal::compatibility::eap::systemd_launcher
      $initsystem       = $jboss::internal::compatibility::eap::initsystem
    }
    'jboss-as': {
      include jboss::internal::compatibility::as
      
      $controller_port  = $jboss::internal::compatibility::as::controller_port
      $product_short    = $jboss::internal::compatibility::as::product_short
      $initd_file       = $jboss::internal::compatibility::as::initd_file
      $systemd_file     = $jboss::internal::compatibility::as::systemd_file
      $systemd_launcher = $jboss::internal::compatibility::as::systemd_launcher
      $initsystem       = $jboss::internal::compatibility::as::initsystem
    }
    default: {
      fail("Unsupported product ${jboss::product}. Supporting only: 'jboss-eap', 'jboss-as' and 'wildfly'")
    }
  }

}
