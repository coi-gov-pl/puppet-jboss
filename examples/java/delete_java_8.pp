if $::osfamily == 'RedHat' {
  $java_packages = [
    'java-1.8.0-openjdk',
    'java-1.8.0-openjdk-devel',
    'java-1.8.0-openjdk-headless',
  ]
} elsif $::osfamily == 'Debian' {
  $java_packages = [
    'openjdk-8-jdk',
    'openjdk-8-jdk-headless',
    'openjdk-8-jre',
    'openjdk-8-jre-headless',
  ]
} else {
  $java_packages = undef
}

if $java_packages != undef {
  package { $java_packages:
    ensure => 'purged',
  }
}
