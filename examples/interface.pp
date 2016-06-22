include jboss

jboss::interface { 'public-additional':
  ensure       => 'present',
  inet_address => $::ipaddress,
}
