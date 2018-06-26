# JBoss AS 7 do not work on Java >= 7
if $::osfamily == 'RedHat' {
  $java_package = 'java-1.6.0-openjdk'
} elsif $::osfamily == 'Debian' {
  $java_package = 'openjdk-6-jre'
} else {
  $java_package = undef
}

class { 'java':
  version => 'absent',
  package => $java_package,
}
