include jboss

ensure_packages(['wget'])

$sourcedir = '/usr/src'
$version  = '2.22.2'
$artifact = 'servlet3-webapp'
$group    = 'org/glassfish/jersey/examples'
$file     = "${artifact}-${version}.war"
$fullpath = "${sourcedir}/${file}"

exec { "wget https://repo1.maven.org/maven2/${group}/${artifact}/${version}/${file}":
  alias   => 'wget',
  path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  cwd     => $sourcedir,
  creates => $fullpath,
  require => Package['wget'],
}

jboss::deploy { $file:
  ensure  => 'present',
  path    => $fullpath,
  require => Exec['wget'],
  # servergroup => 'foobar-group', # on domain mode
}
