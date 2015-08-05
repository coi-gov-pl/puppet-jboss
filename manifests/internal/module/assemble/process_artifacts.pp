# Internal define - processing artifacts
define jboss::internal::module::assemble::process_artifacts (
  $dir,
  $uri = $name,
) {
  include jboss
  $base = jboss_basename($uri)
  $target_dir = "${jboss::home}/${dir}"
  if $uri =~ /^(?:http|https|ftp|sftp|ftps):/ {
    jboss::internal::util::fetch::file { $base:
      address   => $uri,
      fetch_dir => $target_dir,
      notify    => Service[$jboss::product],
      require   => Anchor['jboss::package::end'],
    }
  } else {
    file { "${target_dir}/${base}":
      source => $uri,
      mode   => '0640',
      owner  => $jboss::jboss_user_actual,
      group  => $jboss::jboss_group_actual,
      notify => Service[$jboss::product],
    }
  }
}
