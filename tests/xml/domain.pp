jboss::xml::domain { 'label of resource':
  path => '/tmp/path/to/domain-to-deploy.xml',
  ensure => 'present',
}

# or

jboss::xml::domain { '/tmp/path/to/domain-to-deploy.xml':
  ensure => 'present',
}

# or

jboss::xml::domain { 'label of second resource':
  ensure  => 'present',
  content => '<xml>Content</xml>',
}