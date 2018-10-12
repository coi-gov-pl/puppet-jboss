include jboss

jboss::clientry { '/subsystem=messaging/hornetq-server=default':
  ensure     => 'present',
  properties => {
    'security-enabled' => true,
  }
}
