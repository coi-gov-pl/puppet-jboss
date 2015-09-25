# Root logger for JBoss
define jboss::logging::root (
  $logger_name = $name,
  $ensure      = 'present',
  $level       = 'INFO',
  $handlers    = [ 'CONSOLE', 'FILE' ],
) {

  jboss::clientry { "/subsystem=logging/root-logger=${logger_name}":
    ensure     => $ensure,
    dorestart  => false,
    properties => {
      'level'    => $level,
      'handlers' => $handlers,
    },
  }
}
