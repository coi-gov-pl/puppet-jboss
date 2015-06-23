# Internal define. Default download method.
define jboss::internal::util::download (
  $fetch_dir,
  $mode,
  $owner,
  $group,
  $uri          = $name,
  $timeout      = 900,
  $filename     = undef,
  $install_wget = true,
) {
  anchor { "jboss::internal::util::fetch::begin(${name})": }

  if $filename == undef {
    $base = jboss_basename($uri)
    $dest = "${fetch_dir}/${base}"
  } else {
    $dest = "${fetch_dir}/${filename}"
  }

  validate_string($dest)
  validate_re($dest, '^.+$')

  case $uri {
    /^(?:http|https|ftp|sftp|ftps):/ : {
      if ! defined(Package['wget']) and $install_wget {
        ensure_packages(['wget'])
      }

      exec { "wget -q '${uri}' -O '${dest}' && chmod ${mode} '${dest}' && chown ${owner}:${group} '${dest}'":
        alias   => "download ${name}",
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates => $dest,
        timeout => $timeout,
        require => [
          Package['wget'],
          Anchor["jboss::internal::util::fetch::begin(${name})"],
        ],
        before  => Anchor["jboss::internal::util::fetch::end(${name})"],
      }
    }
    default : {
      file { $dest:
        alias   => "download ${name}",
        mode    => $mode,
        owner   => $owner,
        group   => $group,
        source  => $uri,
        require => Anchor["jboss::internal::util::fetch::begin(${name})"],
        before  => Anchor["jboss::internal::util::fetch::end(${name})"],
      }
    }
  }

  anchor { "jboss::internal::util::fetch::end(${name})":
    require => Anchor["jboss::internal::util::fetch::begin(${name})"],
  }
}
