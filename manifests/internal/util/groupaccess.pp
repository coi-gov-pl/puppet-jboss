# Internal define - Sets group access recorsivily
define jboss::internal::util::groupaccess (
  $group,
  $user  = undef,
  $dir   = undef,
) {
  $target = $dir ? {
    undef   => $name,
    default => $dir,
  }

  exec { "g+s ${name}":
    command => "find ${target} -type d -exec chmod g+s {} +",
    unless  => "test $(stat -c '%a' ${target} | cut -c2) == '7'",
    notify  => Exec["rw ${name}"],
  }

  exec { "rw ${name}":
    command     => "chmod -R g+rw ${target}",
    refreshonly => true,
  }

  exec { "group ${name}":
    command => "chown -R ${user}:${group} ${target}",
    unless  => "test $(stat -c '%U:%G' ${target}) == '${user}:${group}'",
  }
}
