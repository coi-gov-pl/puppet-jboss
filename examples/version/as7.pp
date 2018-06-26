# JBoss AS 7 do not work on Java >= 7
if $::osfamily == 'RedHat' {
  $java_package = 'java-1.6.0-openjdk'
} else {
  $java_package = undef
}

class { 'jboss':
  product      => 'jboss-as',
  version      => '7.1.1.Final',
  java_package => $java_package,
}
