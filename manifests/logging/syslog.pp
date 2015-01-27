# A JBoss syslog definition
define jboss::logging::syslog (
  $logger_name    = $name,
  $ensure         = 'present',
  $level          = 'INFO',
  $app_name       = 'java-app',
  $port           = 514,
  $serverhost     = "localhost",
  $clienthostname = undef,
  $format         = "RFC5424",
) {

  jboss::clientry { "/subsystem=logging/syslog-handler=${logger_name}":
    ensure     => $ensure,
    dorestart  => false,
    properties => {
      'level'           => $level,
      'app-name'        => $app_name,
      'port'            => $port,
      'server-address'  => $serverhost,
      'syslog-format'   => $format,
    },
  }
}
