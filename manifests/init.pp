define setgroupaccess ($user, $group, $dir) {
    anchor {"jboss::setgroupaccess::${name}::begin": } ->
    exec { "rwX $name":
        command => "chmod -R g=rwX ${dir}",
        unless  => "test $(stat -c '%a' ${dir} | cut -c2) == '7'"
    } ~>
    exec { "find $name":
        command     => "find $dir -type d -exec chmod g+s {} +",
        refreshonly => true,
    }
    exec { "group $name":
        command => "chown -R $user:$group $dir",
        unless  => "test $(stat -c '%U:%G' ${dir}) == '${user}:${group}'"
    }

    anchor {"jboss::setgroupaccess::${name}::end":
        require => [ Anchor["jboss::setgroupaccess::${name}::begin"], Exec["rwX $name"], Exec["group $name"], ],
    }
}

define jboss::module(
    $jboss_home,
    $layer,
    $file) {
    if(!defined(File["${jboss_home}/modules/system/layers/${layer}"])) {
        file {"${jboss_home}/modules/system/layers/${layer}":
            ensure  => 'directory',
            owner   => $jboss::params::jboss_user,
            group   => $jboss::params::jboss_group,
            require => Anchor['jboss::installed'],
        }
    }

    if(!defined(Exec["layer_${layer}"])) {
        exec {"layer_${layer}":
            command => "/bin/awk -F'=' 'BEGIN {ins = 0} /^layers=/ { ins = ins + 1; print \$1=${layer},\$2 } END {if(ins == 0) print \"layers=${layer},base\"}' > ${jboss_home}/modules/layers.conf",
            unless  => "/bin/egrep -e '^layers=.*${layer}.*' ${jboss_home}/modules/layers.conf",
            require => File["${jboss_home}/modules/system/layers/${layer}"],
            
        }
    }
    $file_tmp = inline_template("/${jboss_home}/modules/system/layers/<%= File.basename(scope.lookupvar('file')) %>")
    file {"mktmp_layer_file_${file}":
        name    => $file_tmp,
        ensure  => 'file',
        source  => $file,
        require => Exec["layer_${layer}"],
        backup  => false,
    } ~>
    exec {"untgz $file":
        command     => "/bin/tar -C ${jboss_home}/modules/system/layers/${layer} -zxf ${file_tmp}",
        #onlyif      => "cd ${jboss_home}; tar -ztf ${file_tmp} | xargs ls",
        refreshonly => true,
    }
}

define jboss::user(
    $user = $name,
    $password,
    $realm = 'ManagementRealm',
    $jboss_home,
    ) {
    case $realm {
        'ManagementRealm': {
            exec {"add jboss user ${name}/${realm}":
                environment => ["JBOSS_HOME=${jboss_home}", ],
                command     => "${jboss_home}/bin/add-user.sh -u ${name} -p ${password} -s",
                unless      => "/bin/egrep -e '^${name}=' ${jboss_home}/domain/configuration/mgmt-users.properties",
                logoutput   => 'on_failure',
            }
        }
        'ApplicationRealm': {
            exec {"add jboss user ${name}/${realm}":
                environment => ["JBOSS_HOME=${jboss_home}", ],
                command     => "${jboss_home}/bin/add-user.sh -u ${name} -p ${password} -s -a",
                unless      => "/bin/egrep -e '^${name}=' ${jboss_home}/domain/configuration/application-users.properties",
                logoutput   => 'on_failure',
            }
        }
        default: {
            fail("Unknown realm ${realm} for jboss::user")
        }
    }
}

class jboss (
  $hostname         = $jboss::params::hostname,
  $jboss_user       = $jboss::params::jboss_user,
  $jboss_group      = $jboss::params::jboss_group,
  $package_name     = $jboss::params::package_name,
  $version          = $jboss::params::version,
  $java_autoinstall = $jboss::params::java_autoinstall,
  $java_version     = $jboss::params::java_version,
  $java_package     = $jboss::params::java_package,
  $install_dir      = $jboss::params::install_dir,
  $runasdomain      = $jboss::params::runasdomain,
  $enableconsole    = $jboss::params::enableconsole,
  $controller       = $jboss::params::controller,
  $profile          = $jboss::params::profile,
  $prerequisites    = Class['jboss::internal::prerequisites'],
) inherits jboss::params {

  $home = "${install_dir}/jboss-${version}"

  include jboss::internal::configuration
  include jboss::internal::service

  class { 'jboss::internal::package':
    version          => $version,
    jboss_user       => $jboss_user,
    jboss_group      => $jboss_group,
    package_name     => $package_name,
    java_autoinstall => $java_autoinstall,
    java_version     => $java_version,
    java_package     => $java_package,
    install_dir      => $install_dir,
    prerequisites    => $prerequisites,
    require          => Anchor['jboss::begin'],
  }
  include jboss::internal::package

  anchor { 'jboss::begin': }

  anchor { 'jboss::end':
    require => [
      Class['jboss::internal::package'],
      Class['jboss::internal::configuration'],
      Class['jboss::internal::service'],
      Anchor['jboss::begin'],
      Anchor['jboss::package::end'],
      Anchor['jboss::service::end'],
    ],
  }
}

