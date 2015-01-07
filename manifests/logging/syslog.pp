define jboss::logging::syslog (
  $handler_name = $name,
  $app_name,
  $level = 'ALL',
  $port = 514,
  $enabled = true,
  $ensure = "present",
  $serverhost = "localhost",
  $clienthostname = undef,
  format = "RFC5424",
) {

  jboss::clientry { "/subsystem=logging/syslog-handler=${handler_name}":
    ensure => $ensure,
    properties => {
      'port' => $port,
      'app-name' => $app_name,
      'level' => $level,
      'enabled' => $enabled,
      'server-address' => $serverhost,
      'syslog-format' => $format,
    },
  }
  jboss::clientry { "/subsystem=logging/logger=${handler_name}":
    ensure => $ensure,
    properties => {
      'level' => $level,
      'handlers' => [ $handler_name ],
      'use-parent-handlers' => false,
    },
  }
}
