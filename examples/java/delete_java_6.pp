if $::osfamily == 'RedHat' {
  $java_packages = [
    'java-1.6.0-openjdk',
    'java-1.6.0-openjdk-devel',
  ]
} elsif $::osfamily == 'Debian' {
  $java_packages = [
    'openjdk-6-jdk',
    'openjdk-6-jre',
    'openjdk-6-jre-headless',
  ]
} else {
  $java_packages = undef
}

if $java_packages != undef {
  package { $java_packages:
    ensure => 'purged',
  }
}
