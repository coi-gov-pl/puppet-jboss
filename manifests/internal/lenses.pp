# Installs lenses file for JBoss .xml files
class jboss::internal::lenses {
  include jboss

  $lenses_path = "${::jboss::home}/lenses"

  file { $lenses_path:
    ensure  => 'directory',
    owner   => $::jboss::jboss_user_actual,
    require => Anchor['jboss::configuration::begin'],
  }

  file { "${lenses_path}/jbxml.aug":
    ensure  => 'file',
    source  => 'puppet:///modules/jboss/jbxml.aug',
    owner   => $::jboss::jboss_user_actual,
    require => File[$lenses_path],
    before  => Anchor['jboss::configuration::end'],
  }
}
