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
  include jboss
  include jboss::internal::params

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
      if !defined(Package['wget']) and $install_wget {
        ensure_packages(['wget'])
      }

      if $jboss::superuser and !defined(Group[$group]) {
        ensure_resource('group', $group, {
          ensure => 'present',
        })
        Group[$group] -> Exec["download ${name}"]
      }

      if $jboss::superuser and !defined(User[$owner]) {
        ensure_resource('user', $owner, {
          ensure => 'present',
          gid    => $group,
        })
        User[$owner] -> Exec["download ${name}"]
      }

      exec { "wget -q '${uri}' -O '${dest}' && chmod ${mode} '${dest}' && chown ${owner}:${group} '${dest}'":
        alias     => "download ${name}",
        logoutput => 'on_failure',
        path      => $jboss::internal::params::syspath,
        creates   => $dest,
        timeout   => $timeout,
        require   => Package['wget'],
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
