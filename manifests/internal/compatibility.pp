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
    }
    'jboss-eap': {
      include jboss::internal::compatibility::eap

      $controller_port  = $jboss::internal::compatibility::eap::controller_port
      $product_short    = $jboss::internal::compatibility::eap::product_short
      $initd_file       = $jboss::internal::compatibility::eap::initd_file
      $systemd_file     = $jboss::internal::compatibility::eap::systemd_file
      $systemd_launcher = $jboss::internal::compatibility::eap::systemd_launcher
    }
    'jboss-as': {
      include jboss::internal::compatibility::as

      $controller_port  = $jboss::internal::compatibility::as::controller_port
      $product_short    = $jboss::internal::compatibility::as::product_short
      $initd_file       = $jboss::internal::compatibility::as::initd_file
      $systemd_file     = $jboss::internal::compatibility::as::systemd_file
      $systemd_launcher = $jboss::internal::compatibility::as::systemd_launcher
    }
    default: {
      fail("Unsupported product ${jboss::product}. Supporting only: 'jboss-eap', 'jboss-as' and 'wildfly'")
    }
  }

  include jboss::internal::compatibility::java

  $system_java   = $jboss::internal::compatibility::java::system_java
  $jdk           = $jboss::internal::compatibility::java::jdk
  $java_required = jboss_required_java($::osfamily, $jboss::product, $jboss::version)
  $initsystem    = jboss_to_s($::jboss_initsystem)

  if jboss_to_bool($jboss::java_autoinstall) and ! jboss_member($java_required, $system_java) {
    $capitalized_product     = capitalize($jboss::product)
    $inspected_java_required = jboss_inspect($java_required)
    $versioned_name   = "${::operatingsystem} ${::operatingsystemrelease}"
    $warn1 = "${capitalized_product} ${jboss::version} requires Java release thats one of ${inspected_java_required} "
    $warn2 = "to operate. Module coi/jboss will install default system Java for ${versioned_name} witch is "
    $warn3 = "${system_java} (${jdk}). ${capitalized_product} server will propably not start or crash after starting!"
    $warn4 = "Install required Java version and set flag \$jboss::java_autoinstall to false to suppress this warning."
    $not_start_warn = "${warn1}${warn2}${warn3}"
    warning($not_start_warn)
    warning($warn4)
    $expect_to_start = false
  } else {
    $expect_to_start = true
  }
}
