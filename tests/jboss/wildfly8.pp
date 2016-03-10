class { 'jboss':
  product      => 'wildfly',
  version      => '8.2.1.Final',
  # FIXME: Download url shouldn't be nessesary - GH Issue #65
  download_url => 'http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.zip',
}
