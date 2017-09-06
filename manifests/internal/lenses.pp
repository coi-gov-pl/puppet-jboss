# Installs lenses file for JBoss .xml files
class jboss::internal::lenses {
  include jboss

  $lenses_path = "${jboss::home}/lenses"

  file { $lenses_path:
    ensure  => 'directory',
    owner   => $::jboss::jboss_user,
    require => Anchor['jboss::configuration::begin'],
  }
}
