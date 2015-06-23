# Logging to file for JBoss
define jboss::logging::file (
  $logger_name = $name,
  $ensure      = 'present',
  $level       = 'INFO',
  $formatter   = '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n',
  $suffix      = '.yyyy-MM-dd',
  $relative_to = 'jboss.server.log.dir',
  $file_path   = 'server.log',
) {

  $file = {
    'relative-to' => $relative_to,
    'path'        => $file_path,
  }

  jboss::clientry { "/subsystem=logging/periodic-rotating-file-handler=${logger_name}":
    ensure     => $ensure,
    dorestart  => false,
    properties => {
      'level'     => $level,
      'formatter' => $formatter,
      'suffix'    => $suffix,
      'file'      => $file,
    },
  }
}
