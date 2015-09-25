# Console logging for JBoss
define jboss::logging::console (
  $logger_name = $name,
  $ensure      = 'present',
  $level       = 'INFO',
  $formatter   = '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n',
  $target      = 'System.out',
) {

  jboss::clientry { "/subsystem=logging/console-handler=${logger_name}":
    ensure     => $ensure,
    dorestart  => false,
    properties => {
      'level'     => $level,
      'target'    => $target,
      'formatter' => $formatter,
    },
  }
}
