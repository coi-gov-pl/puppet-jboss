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

      if ! defined(Group[$group]) {
        ensure_resource('group', $group, {
          ensure => 'present',
        })
      }

      if ! defined(User[$owner]) {
        ensure_resource('user', $owner, {
          ensure => 'present',
          gid    => $group,
        })
      }

      exec { "wget -q '${uri}' -O '${dest}' && chmod ${mode} '${dest}' && chown ${owner}:${group} '${dest}'":
        alias     => "download ${name}",
        logoutput => 'on_failure',
        path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        creates   => $dest,
        timeout   => $timeout,
        require   => [
          Package['wget'],
          Group[$group],
          User[$owner],
        ],
      }
    }
    default : {
      file { $dest:
        alias  => "download ${name}",
        mode   => $mode,
        owner  => $owner,
        group  => $group,
        source => $uri,
      }
    }
  }

}
