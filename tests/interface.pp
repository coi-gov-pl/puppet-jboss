include jboss

jboss::interface { 'public':
  ensure       => 'present',
  inet_address => '192.168.5.33',
}