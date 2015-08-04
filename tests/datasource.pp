include jboss

# Non-XA data source
jboss::datasource { 'test-datasource':
  ensure     => 'present',
  username   => 'test-username',
  password   => 'test-password',
  jdbcscheme => 'h2:mem',
  dbname     => 'testing;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE',
  host       => '',
  port       => '',
  driver     => {
    'name'       => 'h2',
  }
}

# XA data source
jboss::datasource { 'test-xa-datasource':
  ensure     => 'present',
  xa         => true,
  username   => 'test-username',
  password   => 'test-password',
  jdbcscheme => 'h2:mem',
  dbname     => 'testing-xa;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE',
  host       => '',
  port       => '',
  driver     => {
    'name'                            => 'h2',
    'driver-xa-datasource-class-name' => 'org.h2.jdbcx.JdbcDataSource'
  }
}
