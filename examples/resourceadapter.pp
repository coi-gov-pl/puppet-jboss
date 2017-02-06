include jboss

ensure_packages(['wget'])

$sourcedir = '/usr/src'
$version  = '2.1.0'
$artifact = 'genericconnector-rar'
$group    = 'ch/maxant'
$file     = "${artifact}-${version}.rar"
$fullpath = "${sourcedir}/${file}"

exec { "wget https://repo1.maven.org/maven2/${group}/${artifact}/${version}/${file}":
  alias   => 'wget',
  path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  cwd     => $sourcedir,
  creates => $fullpath,
  require => Package['wget'],
}

jboss::resourceadapter { 'genericconnector.rar':
  archive            => 'genericconnector.rar',
  transactionsupport => 'XATransaction',
  classname          => 'ch.maxant.generic_jca_adapter.ManagedTransactionAssistanceFactory',
  jndiname           => 'java:/jboss/jca-generic',
}

jboss::deploy { 'genericconnector.rar':
  path    => $fullpath,
  require => [
    JBoss::Resourceadapter['genericconnector.rar'],
    Exec['wget'],
  ],
}
