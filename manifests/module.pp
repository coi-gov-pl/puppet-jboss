define jboss::module (
  $layer, 
  $file,
  $jboss_home = undef, # Deprecated, it is not needed, will be removed
) {
  include jboss
  
  $home = $jboss_home ? { # Deprecated, it is not needed, will be removed
    undef   => $jboss::home,
    default => $jboss_home,
  }
  
  if (!defined(File["${home}/modules/system/layers/${layer}"])) {
    file { "${home}/modules/system/layers/${layer}":
      ensure => 'directory',
      owner  => $jboss::jboss_user,
      group  => $jboss::jboss_group,
    }
  }

  if (!defined(Exec["layer_${layer}"])) {
    exec { "layer_${layer}":
      command => "/bin/awk -F'=' 'BEGIN {ins = 0} /^layers=/ { ins = ins + 1; print \$1=${layer},\$2 } END {if(ins == 0) print \"layers=${layer},base\"}' > ${home}/modules/layers.conf",
      unless  => "/bin/egrep -e '^layers=.*${layer}.*' ${home}/modules/layers.conf",
      require => File["${home}/modules/system/layers/${layer}"],
    }
  }
  $file_basename = jboss_basename($file)
  $file_tmp = inline_template("${home}/modules/system/layers/${file_basename}")
  file { "mktmp_layer_file_${file}":
    path    => $file_tmp,
    ensure  => 'file',
    source  => $file,
    require => Exec["layer_${layer}"],
    backup  => false,
  } ~>
  exec { "untgz $file":
    command     => "/bin/tar -C ${home}/modules/system/layers/${layer} -zxf ${file_tmp}",
    # onlyif      => "cd ${home}; tar -ztf ${file_tmp} | xargs ls",
    refreshonly => true,
  }
}