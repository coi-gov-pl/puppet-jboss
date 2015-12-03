# == Class: jboss::internal::quirks::autoinstall
# Deprcated, will deleted in next major version
class jboss::internal::quirks::autoinstall {
  $dep_key                = 'jboss::params::java_install'
  $is_set                 = hiera($dep_key, undef)
  if $is_set != undef {
    warning("Hiera key ${dep_key} is deprecated, please use jboss::params::java_autoinstall instead.")
  }
  $deprecated_java_install = jboss_to_bool(hiera($dep_key, true))
}
