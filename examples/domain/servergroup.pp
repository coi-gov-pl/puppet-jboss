include jboss

jboss::domain::servergroup { 'app-group':
  ensure            => 'present',
  profile           => 'full-ha',
  heapsize          => '2048m',
  maxheapsize       => '2048m',
  jvmopts           => '-XX:+UseG1GC -XX:MaxGCPauseMillis=200',
  system_properties => {
    'java.security.egd' => 'file:/dev/urandom',
  }
}