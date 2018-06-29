if $::osfamily == 'RedHat' {
  $java_package = 'java-1.8.0-openjdk-headless'
} elsif $::osfamily == 'Debian' {
  $java_package = 'openjdk-8-jre-headless'
} else {
  $java_package = undef
}

class { 'jboss':
  product      => 'wildfly',
  version      => '10.1.0.Final',
  java_package => $java_package,
}
