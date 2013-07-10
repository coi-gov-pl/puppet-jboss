class jboss inherits jboss::params {
  include jboss::download
  $download_dir = '/opt/download'
  $download_file = "jboss-$version.zip"
  $jboss_parent_dir = '/usr/local/lib'
  $jboss_dir = "jboss-$version"
  $jboss_download_site = "http://public.prs.jakby.co/Virtualki"
  $jboss_path = "$jboss_parent_dir/$jboss_dir"

  user { $jboss::params::jboss_user:
    ensure     => "present",
    managehome => true
  }

  group { $jboss::params::jboss_group:
    ensure  => "present",
    require => User[$jboss::params::jboss_user],
    members => User[$jboss::params::jboss_user],
  }

  file { $jboss_path:
    group => $jboss::params::jboss_group,
    owner => $jboss::params::jboss_user,
    mode  => 2775
  }
  
  file { jboss-as:
    path => "/etc/jboss-as",
    ensure => directory,
    group => $jboss::params::jboss_group,
    owner => $jboss::params::jboss_user,
    mode  => 2775
  }



  file { $jboss_parent_dir:
    ensure => 'directory',
  }

  Exec {
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  }

  file { $download_dir:
    ensure => 'directory',
  }

  jboss::download::download { "$download_dir/$zip_name":
    uri     => "$jboss_download_site/$zip_name",
    require => [File[$jboss_path], File[$jboss_parent_dir], File[$download_dir],]
  }

  package { unzip:
    ensure => "installed"
  }
  
   package { "java-1.6.0-openjdk-devel.x86_64":
    ensure => "installed"
  }

  file { "$download_dir/$jboss_dir":
  }

  file { "$download_dir/$download_file":
  }

  exec { 'unzip-downloaded':
    command => "unzip $zip_name",
    cwd     => $download_dir,
    creates => $jboss_path,
    require => [File["$download_dir/$download_file"], Package[unzip]]
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
    user    => $jboss::params::jboss_user,
    group   => $jboss::params::jboss_group,
    require => Group[$jboss::params::jboss_group],
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

  #  file { servicefile:
  #    path    => "/etc/init.d/jboss",
  #    mode    => 755,
  #    #content => template('jboss/jboss2.erb'),
  #    content => template('jboss/jboss-init.erb'),
  #    notify  => Service["jboss"]
  #  }

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
  #    require    => [File[$jboss_path], File[servicefile],
  #      #Class[java7],
  #    ]
  }

  Jboss::Download::Download["$download_dir/$zip_name"] -> Exec['unzip-downloaded'] -> Setgroupaccess['set-perm'] -> Exec[
    'move-downloaded'] -> Exec['jboss-service-link'] -> File[jboss-as] -> File[jboss-as-conf] -> File[jbosscli]

  # File[servicefile] -> Service['jboss']
  File[jboss-as-conf] -> Service['jboss']
}

