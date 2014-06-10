define jboss::internal::module::fromfile (
  $layer, 
  $file,
  $jboss_home = undef, # Deprecated, it is not needed, will be removed
) {
  include jboss
  
  $home = $jboss_home ? { # Deprecated, it is not needed, will be removed
    undef   => $jboss::home,
    default => $jboss_home,
  }
  
  if (!defined(File["jboss::module::fromfile::${layer}"])) {
    file { "jboss::module::fromfile::${layer}":
      alias  => "${home}/modules/system/layers/${layer}", # Deprecated
      path   => "${home}/modules/system/layers/${layer}",
      ensure => 'directory',
      owner  => $jboss::jboss_user,
      group  => $jboss::jboss_group,
      notify => Service['jboss'],
    }
  }

  $file_basename = jboss_basename($file)
  $file_tmp = "${home}/modules/system/layers/${file_basename}"
  
  file { "jboss::module::fromfile::mktmplayerfile(${file})":
    alias   => "mktmp_layer_file_${file}", # Deprecated
    path    => $file_tmp,
    ensure  => 'file',
    source  => $file,
    require => Exec["jboss::module::layer::${layer}"],
    notify  => Service['jboss'],
    backup  => false,
  }
  exec { "jboss::module::fromfile::untgz($file)":
    alias       => "untgz $file", # Deprecated
    command     => "/bin/tar -C ${home}/modules/system/layers/${layer} -zxf ${file_tmp}",
    refreshonly => true,
    subscribe   => File["jboss::module::fromfile::mktmplayerfile(${file})"],
    notify      => Service['jboss'],
    # onlyif      => "cd ${home}; tar -ztf ${file_tmp} | xargs ls",
  }
  
  jboss::internal::module::registerlayer { "jboss::module::fromfile::${name}($layer)":
    layer   => $layer,
    require => Exec["jboss::module::fromfile::untgz($file)"],
  }
}