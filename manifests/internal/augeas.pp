# Internal class - defaults for augeas provider
class jboss::internal::augeas {
  include jboss
  include jboss::internal::lenses
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
