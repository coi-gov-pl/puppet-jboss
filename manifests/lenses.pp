# Installs lenses file for JBoss .xml files
class jboss::lenses {
  $lenses_path = "${::jboss::home}/lenses"
  file{$lenses_path:
    ensure  => directory,
    owner   => $::jboss::jboss_user,
    require => Anchor['jboss::configuration::begin'],
  } ->
  file {"${lenses_path}/jbxml.aug":
    ensure  => present,
    source  => 'puppet:///jboss/jbxml.aug',
    owner   => $::jboss::jboss_user,
    before  => Anchor['jboss::configuration::end'],
  }
}
