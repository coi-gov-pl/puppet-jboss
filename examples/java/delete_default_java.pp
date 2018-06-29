include java::params

$jdk = $java::params::java['jdk']['package']
$jre = $java::params::java['jre']['package']

package { [$jdk, $jre]:
  ensure => 'purged',
}
