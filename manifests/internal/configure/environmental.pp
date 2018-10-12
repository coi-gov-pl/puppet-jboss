# @summary Configures environmental variables
# @api private
class jboss::internal::configure::environmental {
  include jboss
  include jboss::internal::configuration
  $environment = $jboss::environment

  validate_hash($environment)

  $keys = keys($environment)

  jboss::internal::configure::envvariable { $keys:
    values  => $environment,
  }
}
