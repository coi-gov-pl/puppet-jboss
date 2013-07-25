class jboss (
  $jboss_user = $jboss::params::jboss_user,
  $jboss_group = $jboss::params::jboss_group,
  $jboss_download = $jboss::params::jboss_download,
  $version = $jboss::params::version,
  $java_version = $jboss::params::java_version,
) inherits jboss::params {
  
  include jboss::download
  $download_dir = '/opt/download'
  $download_file = "jboss-$version.zip"
  $jboss_parent_dir = '/usr/local/lib'
  $jboss_dir = "jboss-$version"
  $jboss_path = "$jboss_parent_dir/$jboss_dir"

  user { $jboss_user:
    ensure     => "present",
    managehome => true,
  }

  group { $jboss_group:
    ensure  => "present",
    require => User[$jboss_user],
    members => User[$jboss_user],
  }

  file { $jboss_path:
    group => $jboss_group,
    owner => $jboss_user,
    mode  => 2775,
  }

  file { jboss-as:
    path   => "/etc/jboss-as",
    ensure => directory,
    group  => $jboss_group,
    owner  => $jboss_user,
    mode   => 2775,
  }
  
  class { 'java':
	  distribution => 'jdk',
	  version      => $java_version,
	}

  file { $jboss_parent_dir: ensure => 'directory', }

  Exec {
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", 
  }

  file { $download_dir: ensure => 'directory', }

  jboss::download::download { "$download_dir/$download_file":
    uri     => "$jboss_download",
    require => [
      File[$jboss_path], 
      File[$jboss_parent_dir], 
      File[$download_dir],
    ],
  }

  package { unzip: ensure => "installed" }
  

  file { "$download_dir/$jboss_dir": }

  file { "$download_dir/$download_file": }

  exec { 'unzip-downloaded':
    command => "unzip $download_file",
    cwd     => $download_dir,
    creates => $jboss_path,
    require => [
      File["$download_dir/$download_file"], 
      Package[unzip]
    ],
  }

  define setgroupaccess ($user, $group, $dir, $glpath) {
    exec { "rwX $name":
      command => "chmod -R g+rwX $dir",
      creates => $glpath,
    }

    exec { "find $name":
      command => "find $dir -type d -exec chmod g+s {} +",
      creates => $glpath,
    }

    exec { "group $name":
      command => "chown -R $user:$group $dir",
      creates => $glpath,
    }
  }

  setgroupaccess { 'set-perm':
    user    => $jboss_user,
    group   => $jboss_group,
    require => Group[$jboss_group],
    dir     => "$download_dir/$jboss_dir",
    glpath  => $jboss_path,
  }

  exec { 'move-downloaded':
    command => "mv $download_dir/$jboss_dir $jboss_path",
    cwd     => $download_dir,
    creates => $jboss_path,
  }

  exec { 'jboss-service-link':
    command => "ln -s $jboss_path/bin/init.d/jboss-as-domain.sh /etc/init.d/jboss",
    unless  => "test -f /etc/init.d/jboss",
  }

  file { jboss-as-conf:
    path    => "/etc/jboss-as/jboss-as.conf",
    mode    => 755,
    content => template('jboss/jboss-as.conf.erb'),
    notify  => Service["jboss"]
  }

  file { jbosscli:
    content => template('jboss/jboss-cli.erb'),
    mode    => 755,
    path    => '/usr/bin/jboss-cli',
    notify  => Service["jboss"]
  }

  service { "jboss":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  Jboss::Download::Download["$download_dir/$download_file"] -> Exec['unzip-downloaded'] -> Setgroupaccess['set-perm'] -> Exec['move-downloaded'
    ] -> Exec['jboss-service-link'] -> File[jboss-as] -> File[jboss-as-conf] -> File[jbosscli]

  # File[servicefile] -> Service['jboss']
  File[jboss-as-conf] -> Service['jboss']
}

