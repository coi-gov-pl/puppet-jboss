# Internal class - Quircks for /etc/init.d/functions loading from RHEL even on Debian like systems
class jboss::internal::quirks::etc_initd_functions {
  include jboss
  include jboss::internal::params
  include jboss::internal::service
  include jboss::internal::compatibility

  if $jboss::product != 'wildfly' and $::osfamily == 'Debian' {
    file { '/sbin/consoletype':
      content => join(['#!/bin/sh', 'echo pty'], "\n"),
      mode    => '0755',
    }
    file { '/etc/init.d/functions':
      ensure  => 'file',
      source  => 'puppet:///modules/jboss/rhel-initd-functions.sh',
      require => File['/sbin/consoletype'],
      notify  => Service[$jboss::internal::service::servicename],
    }
    exec { "sed -i '1s/.*/#!\\/bin\\/bash/' ${jboss::internal::compatibility::initd_file}":
      onlyif  => "test \"$(head -n 1 ${jboss::internal::compatibility::initd_file})\" = '#!/bin/sh'",
      require => Anchor['jboss::package::end'],
      notify  => Service[$jboss::internal::service::servicename],
      path    => $jboss::internal::params::syspath,
    }
  }
}
