define jboss::module::registerlayer (
  $layer = name,
) {
  include jboss
  
  File {
    mode   => '0640',
    owner  => $jboss::jboss_user,
    group  => $jboss::jboss_group,    
  }

  if (!defined(Exec["jboss::module::layer::${layer}"])) {
    exec { "jboss::module::layer::${layer}":
      alias   => "layer_${layer}", # Deprecated
      command => "/bin/awk -F'=' 'BEGIN {ins = 0} /^layers=/ { ins = ins + 1; print \$1=${layer},\$2 } END {if(ins == 0) print \"layers=${layer},base\"}' > ${jboss::home}/modules/layers.conf",
      unless  => "/bin/egrep -e '^layers=.*${layer}.*' ${jboss::home}/modules/layers.conf",
      require => Anchor["jboss::installed"],
      notify  => Service['jboss'],
    }
    file { "jboss::module::layer::${layer}":
      ensure  => directory,
      path    => "${jboss::home}/modules/system/layers/${layer}",
      require => Anchor["jboss::installed"],
      notify  => Service['jboss'],
    }
  }
}
