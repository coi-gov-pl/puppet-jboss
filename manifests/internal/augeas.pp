# Internal class - defaults for augeas provider
class jboss::internal::augeas {
  include jboss
  if versioncmp('$::augeasversion', '1.0.0') < 0 {
    # Include additional only for old augeas version
    include jboss::internal::lenses
    $defaults = {
      require   => [
        Anchor['jboss::configuration::begin'],
        File["${jboss::internal::lenses::lenses_path}/jbxml.aug"],
      ],
      notify    => [
        Anchor['jboss::configuration::end'],
        Service[$jboss::product],
      ],
      load_path => $jboss::internal::lenses::lenses_path,
      lens      => 'jbxml.lns',
    }
  } else {
    $defaults = {
      lens      => 'xml.lns',
      require   => [
        Anchor['jboss::configuration::begin'],
      ],
      notify    => [
        Anchor['jboss::configuration::end'],
        Service[$jboss::product],
      ],
    }
  }
}
