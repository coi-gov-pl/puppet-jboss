# Internal define - Assemble JBoss module from files
define jboss::internal::module::assemble (
  $layer,
  $modulename   = $name,
  $artifacts    = [],
  $dependencies = [],
) {
  include jboss

  $replaced = regsubst($modulename, '\.', '/', 'G')
  $dir = "modules/system/layers/${layer}/${replaced}/main"

  File {
    mode   => '0640',
    owner  => $jboss::jboss_user,
    group  => $jboss::jboss_group,
  }

  exec { "jboss::module::assemble::${name}(dir=${dir})":
    command => "/bin/mkdir -p ${jboss::home}/${dir}",
    unless  => "test -d ${jboss::home}/${dir}",
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    notify  => Service[$jboss::product],
    require => Anchor['jboss::package::end'],
  }

  file { "jboss::module::assemble::${name}(dir=${dir})":
    ensure  => 'directory',
    mode    => '2750',
    path    => "${jboss::home}/${dir}",
    notify  => Service[$jboss::product],
    require => [
      Anchor['jboss::package::end'],
      Exec["jboss::module::assemble::${name}(dir=${dir})"]
    ],
  }

  file { "jboss::module::assemble::${name}(module.xml)":
    ensure  => 'file',
    path    => "${jboss::home}/${dir}/module.xml",
    content => template('jboss/module/module.xml.erb'),
    notify  => Service[$jboss::product],
    require => Anchor['jboss::package::end'],
  }

  jboss::internal::module::assemble::process_artifacts { $artifacts:
    dir     => $dir,
    notify  => Service[$jboss::product],
    require => Anchor['jboss::package::end'],
  }

  jboss::internal::module::registerlayer { "jboss::module::assemble::${name}(${layer})":
    layer => $layer,
  }

}
