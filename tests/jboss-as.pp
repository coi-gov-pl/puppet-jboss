class { 'jboss':
  product       => 'jboss-as',
  version       => '7.1.1.Final',
  download_url  => 'http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip',
  enableconsole => true,
}
