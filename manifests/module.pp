# Creates JBoss module
define jboss::module (
  $layer,
  $modulename   = $name,
  $artifacts    = [],
  $dependencies = [],
) {
  include jboss

  jboss::internal::module::assemble { $name:
    layer        => $layer,
    modulename   => $modulename,
    artifacts    => $artifacts,
    dependencies => $dependencies,
  }
}
