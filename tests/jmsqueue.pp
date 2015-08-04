include jboss

jboss::jmsqueue { 'app-mails':
  ensure  => 'present',
  durable => true,
  entries => [
    'queue/app-mails',
    'java:jboss/exported/jms/queue/app-mails',
  ],
}
