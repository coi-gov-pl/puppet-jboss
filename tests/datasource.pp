include jboss
jboss::datasource { 'test-datasource':
  username   => 'test-username',
  password   => 'test-password',
  jdbcscheme => 'test-scheme',
  host       => 'example.com',
  port       => '1234',
  driver     => {
    'name'       => 'test-driver',
    'classname'  => 'com.example.TestDriver',
    'modulename' => 'test-driver',
  }
}
