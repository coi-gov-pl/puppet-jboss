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
            ensure => 'directory',
            owner  => $jboss::params::jboss_user,
            group  => $jboss::params::jboss_group,
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
  $jboss_user = $jboss::params::jboss_user,
  $jboss_group = $jboss::params::jboss_group,
  $download_url = $jboss::params::download_url,
  $download_dir = $jboss::params::download_dir,
  $download_file = inline_template('<%= File.basename( scope.lookupvar("download_url") ) %>'), #(
  $version = $jboss::params::version,
  $java_version = $jboss::params::java_version,
  $java_package = undef,
  $install_dir = $jboss::params::install_dir,
  $jboss_dir = $version,
  $download_dir = "${install_dir}/download-${version}",
  $domain_xml = undef,
  $host_xml = undef,
) inherits jboss::params {
  
  anchor {"jboss::begin": }

  $jboss_home = "$install_dir/$jboss_dir"

    File {
        owner => $jboss_user,
        group => $jboss_group,
        mode  => '2750',
    }
    Exec {
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", 
        logoutput => 'on_failure',
    }

    group { $jboss_group:
        ensure  => 'present',
    }

    user { $jboss_user:
        ensure     => 'present',
        managehome => true,
        gid        => $jboss_group,
    }

    file { $install_dir:
        ensure => 'directory',
        owner  => undef,
        group  => undef,
        mode   => undef,
    }

    file { 'jboss-as':
        path   => '/etc/jboss-as',
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '755',
    }
  
    class { 'java':
	    distribution => 'jdk',
	    version      => $java_version,
        package      => $java_package,
	}

    file { $download_dir:
        ensure => 'directory',
    }

    jboss::download { "${download_dir}/${download_file}":
        uri     => $download_url,
        require => File[$download_dir],
    }

    package { "unzip":
        ensure => "installed"
    }
  
    exec { 'unzip-downloaded':
        command   => "unzip -o -q ${download_dir}/${download_file} -d ${download_dir}",
        cwd       => $download_dir,
        unless    => "find ${download_dir} -type f -name jboss-as-domain.sh | grep jboss-as-domain.sh",
        require   => [
            Jboss::Download["${download_dir}/${download_file}"],
            File[$download_dir],
            Package['unzip']
        ],
    }
  
    exec { 'move-unzipped':
        command => "mv $(find ${download_dir}/ -maxdepth 1 -type d -print | egrep -v '(/|\\.)$') ${jboss_home}",
        creates => $jboss_home,
        require => Exec['unzip-downloaded'],
    }

    exec { 'test-extraction':
        command => "echo '${jboss_home}/bin/init.d not found!' 1>&2; exit 1",
        unless  => "test -d ${jboss_home}/bin/init.d",
        require => Exec['move-unzipped'],
    }

    setgroupaccess { 'set-perm':
        user    => $jboss_user,
        group   => $jboss_group,
        dir     => $jboss_home,
        require => [ User[$jboss_user], Exec['test-extraction'], ],
    }

    exec { 'jboss-service-link':
        command => "ln -sf ${jboss_home}/bin/init.d/jboss-as-domain.sh /etc/init.d/jboss",
        creates => '/etc/init.d/jboss',
        require => Setgroupaccess['set-perm'],
    }

    if($domain_xml) {
        $domain_config = inline_template('<%= File.basename(domain_xml) %>')
        file {'custom jboss domain.xml':
            path   => "${jboss_home}/domain/configuration/${domain_config}_staged",
            ensure => 'present',
            source => $domain_xml,
            notify => [ Service['jboss'], Exec['overwrite domain.xml config'] ],
            before => [ File['jboss-as-conf'], ],
            require => Setgroupaccess['set-perm'],
        }
        # hack: nie nadpisuj pliku króry lokalnie się zmienił, ale jeśli w puppecie się zmienił to nadpisz.
        exec {'overwrite domain.xml config':
            refreshonly => true,
            command     => "/bin/cp ${jboss_home}/domain/configuration/${domain_config}_staged ${jboss_home}/domain/configuration/${domain_config}",
        }
        #--server-config=standalone-ha.xml
        #$JBOSS_DOMAIN_CONFIG = $domain_config
    } else {
        # Default settings
        $domain_config = ''
    }
    if($host_xml) {
        $host_config = inline_template('<%= File.basename(host_xml) %>')
        file {'custom jboss host.xml':
            path    => "${jboss_home}/domain/configuration/$host_config",
            ensure  => 'present',
            source  => $host_xml,
            notify  => Service['jboss'],
            before  => [ File['jboss-as-conf'], ],
            require => Setgroupaccess['set-perm'],
        }
        #$JBOSS_HOST_CONFIG = $host_config
    } else {
        # Default settings
        $host_config = ''
    }
    
    file { 'jboss-as-conf':
        path     => "/etc/jboss-as/jboss-as.conf",
        mode     => 755,
        content  => template('jboss/jboss-as.conf.erb'),
        notify   => Service["jboss"],
        require  => Setgroupaccess['set-perm'],
    }

    file { 'jbosscli':
        content => template('jboss/jboss-cli.erb'),
        mode    => 755,
        path    => '/usr/bin/jboss-cli',
        require => Setgroupaccess['set-perm'],
    }
    anchor { "jboss::installed": }
    service { 'jboss':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => [Class['java'], Exec['jboss-service-link'], Setgroupaccess['set-perm'], File['jboss-as-conf'], Anchor["jboss::installed"], ],
    }

    anchor{ "jboss::end":
        require => [ Anchor['jboss::begin'], File['jbosscli'], Anchor["jboss::installed"], Service['jboss'], ],
    }
}

