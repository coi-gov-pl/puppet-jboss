define jboss::logging::async (
  $logger_name = $name,
  $ensure = 'present',
  $level = 'INFO',
  $formatter = '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n',
  $handlers = [ 'CONSOLE', 'FILE' ],
  $overflow_action = "BLOCK",
  $queue_length = 1024,  
) {

  jboss::clientry { "/subsystem=logging/async-handler=${logger_name}":
    ensure     => $ensure,
    dorestart  => false,
    properties => {
      'level'           => $level,
      'formatter'       => $formatter,
      'subhandlers'     => $handlers,
      'overflow-action' => $overflow_action,
      'queue-length'    => $queue_length,
    },
  }
}
