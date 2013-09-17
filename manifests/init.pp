define setgroupaccess ($user, $group, $dir) {
    anchor {"setgroupaccess::begin": } ->
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

    anchor {"setgroupaccess::end":
        require => [ Exec["rwX $name"], Exec["group $name"], ],
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
    $file_tmp = inline_template('/tmp/<%= File.basename(scope.lookupvar("file")) %>')
    file {"mktmp_layer_file_${file}":
        name    => $file_tmp,
        ensure  => 'file',
        source  => $file,
        require => Exec["layer_${layer}"],
    } ~>
    exec {"untgz $file":
        command     => "/bin/tar -C ${jboss_home}/modules/system/layers/${layer} -zxf ${file_tmp}",
        #onlyif      => "cd ${jboss_home}; tar -ztf ${file_tmp} | xargs ls",
        refreshonly => true,
    }
}

class jboss (
  $jboss_user = $jboss::params::jboss_user,
  $jboss_group = $jboss::params::jboss_group,
  $download_url = $jboss::params::download_url,
  $download_dir = $jboss::params::download_dir,
  $download_file = undef,
  $version = $jboss::params::version,
  $java_version = $jboss::params::java_version,
  $install_dir = $jboss::params::install_dir,
  $jboss_dir = $version,
  $download_dir = "${install_dir}/download-${version}",
  $domain_xml = undef,
  $host_xml = undef,
) inherits jboss::params {
  
  anchor {"jboss::begin": }

  require jboss::download
  $jboss_home = "$install_dir/$jboss_dir"
  if($download_file == undef) {
    $download_file = inline_template('<%= File.basename( scope.lookupvar(download_url) ) %>')
  }

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
	}

    file { $download_dir:
        ensure => 'directory',
    }

    jboss::download::download { "${download_dir}/${download_file}":
        uri     => $download_url,
        require => File[$download_dir],
    }

    package { unzip: ensure => "installed" }
  
    exec { 'unzip-downloaded':
        command   => "unzip -o -q ${download_dir}/${download_file} -d ${download_dir}",
        cwd       => $download_dir,
        unless    => "find ${download_dir} -type f -name jboss-as-domain.sh | grep jboss-as-domain.sh",
        require   => [
            Jboss::Download::Download["${download_dir}/${download_file}"],
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
    service { 'jboss':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => [Class['java'], Exec['jboss-service-link'], Setgroupaccess['set-perm'], File['jboss-as-conf'], ],
    }

    anchor{ "jboss::end":
        require => [ Anchor['jboss::begin'], File['jbosscli'], Service['jboss'], ],
    }
}

