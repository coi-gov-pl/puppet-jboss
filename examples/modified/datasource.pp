class { 'jboss':
  enableconsole => true,
}

jboss::user { 'admin':
  password => 'seCret1!',
}

# Non-XA data source
jboss::datasource { 'test-datasource':
  ensure     => 'present',
  username   => 'test-username-2',
  password   => 'test-password-2',
  jdbcscheme => 'h2:mem',
  # Bug https://github.com/coi-gov-pl/puppet-jboss/issues/108
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
  username   => 'test-username-3',
  password   => 'test-password-3',
  jdbcscheme => 'h2:mem',
  dbname     => 'testing-xa;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE',
  host       => '',
  port       => '',
  driver     => {
    'name'                            => 'h2',
    'driver-xa-datasource-class-name' => 'org.h2.jdbcx.JdbcDataSource'
  }
}
