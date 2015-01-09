define jboss::logging::logger (
  $logger_name = $name,
  $ensure = 'present',
  $level = 'INFO',
  $use_parent_handlers = true,
) {

  jboss::clientry { "/subsystem=logging/logger=${logger_name}":
    ensure     => $ensure,
    dorestart  => false,
    properties => {
      'level'                => $level,
      'use-parent-handlers'  => $use_parent_handlers,
    },
  }
}
