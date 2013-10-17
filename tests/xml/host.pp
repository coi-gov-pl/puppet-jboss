jboss::xml::host { 'label of resource':
  path => '/tmp/path/to/host-to-deploy.xml',
  ensure => 'present',
}

# or

jboss::xml::host { '/tmp/path/to/host-to-deploy.xml':
  ensure => 'present',
}

# or

jboss::xml::host { 'label of second resource':
  ensure  => 'present',
  content => '<xml>Content</xml>',
}