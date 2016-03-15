class { 'jboss':
  product       => 'jboss-as',
  version       => '7.1.1.Final',
  download_url  => 'http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip',
  enableconsole => true,
}

$artifact_version  = "1.0.0"
$artifact_name     = "sample"
$artifact_fullname = "${artifact_name}-${artifact_version}"

file { "${::jboss::install_dir}/${artifact_name}_deployment.state":
  content => "$artifact_fullname",
  notify => Jboss::Deploy["${artifact_name}.war"],
}

jboss::deploy { "${artifact_name}.war":
  ensure      => 'present',
  redeploy    => 'true',
  path        => "/usr/src/${artifact_fullname}.war",
}