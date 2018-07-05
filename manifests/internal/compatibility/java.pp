# == Class: jboss::internal::compatibility::java
#
class jboss::internal::compatibility::java {
  include java::params
  $jdk = $java::params::java['jdk']['package']
  # Develop w/tests: https://regex101.com/r/MjlruX/2
  $strip_java_regex = '.+([5-9]|1[0-9]).*'
  $system_java      = jboss_to_i(regsubst($jdk, $strip_java_regex, '\1'))
}
