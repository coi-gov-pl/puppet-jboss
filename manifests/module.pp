define jboss::module (
  $jboss_home, 
  $layer, 
  $file
) {
  if (!defined(File["${jboss_home}/modules/system/layers/${layer}"])) {
    file { "${jboss_home}/modules/system/layers/${layer}":
      ensure => 'directory',
      owner  => $jboss::params::jboss_user,
      group  => $jboss::params::jboss_group,
    }
  }

  if (!defined(Exec["layer_${layer}"])) {
    exec { "layer_${layer}":
      command => "/bin/awk -F'=' 'BEGIN {ins = 0} /^layers=/ { ins = ins + 1; print \$1=${layer},\$2 } END {if(ins == 0) print \"layers=${layer},base\"}' > ${jboss_home}/modules/layers.conf",
      unless  => "/bin/egrep -e '^layers=.*${layer}.*' ${jboss_home}/modules/layers.conf",
      require => File["${jboss_home}/modules/system/layers/${layer}"],
    }
  }
  $file_tmp = inline_template("/${jboss_home}/modules/system/layers/<%= File.basename(scope.lookupvar('file')) %>")
  file { "mktmp_layer_file_${file}":
    path    => $file_tmp,
    ensure  => 'file',
    source  => $file,
    require => Exec["layer_${layer}"],
    backup  => false,
  } ~>
  exec { "untgz $file":
    command     => "/bin/tar -C ${jboss_home}/modules/system/layers/${layer} -zxf ${file_tmp}",
    # onlyif      => "cd ${jboss_home}; tar -ztf ${file_tmp} | xargs ls",
    refreshonly => true,
  }
}