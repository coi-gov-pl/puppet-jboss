class { 'jboss':
  product      => 'jboss-as',
  version      => '7.1.1.Final',
  # FIXME: Download url shouldn't be nessesary - GH Issue #65
  download_url => 'http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip',
}
