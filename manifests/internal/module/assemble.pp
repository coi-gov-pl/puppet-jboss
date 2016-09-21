# Internal define - Assemble JBoss module from files
define jboss::internal::module::assemble (
  $layer,
  $modulename   = $name,
  $artifacts    = [],
  $dependencies = [],
) {
  include jboss
  include jboss::internal::params
  include jboss::internal::relationship::module_user

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
    path    => $jboss::internal::params::syspath,
    notify  => Service[$jboss::product],
    require => Anchor['jboss::package::end'],
    before  => Anchor['jboss::internal::relationship::module_user'],
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
    before  => Anchor['jboss::internal::relationship::module_user'],
  }

  file { "jboss::module::assemble::${name}(module.xml)":
    ensure  => 'file',
    path    => "${jboss::home}/${dir}/module.xml",
    content => template('jboss/module/module.xml.erb'),
    notify  => Service[$jboss::product],
    require => Anchor['jboss::package::end'],
    before  => Anchor['jboss::internal::relationship::module_user'],
  }

  jboss::internal::module::assemble::process_artifacts { $artifacts:
    dir     => $dir,
    notify  => Service[$jboss::product],
    require => Anchor['jboss::package::end'],
    before  => Anchor['jboss::internal::relationship::module_user'],
  }

  jboss::internal::module::registerlayer { "jboss::module::assemble::${name}(${layer})":
    layer  => $layer,
    before => Anchor['jboss::internal::relationship::module_user'],
  }
}
