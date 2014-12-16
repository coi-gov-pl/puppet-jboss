define jboss::logging::handlers::syslog (
  $handler_name = $name,
  $app_name,
  $level = 'ALL',
  $port = 514,
  $enabled = true,
  $ensure = "present",
  $serverhost = "localhost",
  $clienthostname = undef,
  format = undef,
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
      'name' => $handler_name,
    },
  }
}
