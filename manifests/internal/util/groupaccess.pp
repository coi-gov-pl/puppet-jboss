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

  anchor {"jboss::util::groupaccess::${name}::begin": }

  exec { "g+s ${name}":
    command => "find ${target} -type d -exec chmod g+s {} +",
    unless  => "test $(stat -c '%a' ${target} | cut -c2) == '7'",
    notify  => Exec["rw ${name}"],
    require => Anchor["jboss::util::groupaccess::${name}::begin"],
  }

  exec { "rw ${name}":
    command     => "chmod -R g+rw ${target}",
    require     => Anchor["jboss::util::groupaccess::${name}::begin"],
    refreshonly => true,
  }

  exec { "group ${name}":
    command => "chown -R ${user}:${group} ${target}",
    unless  => "test $(stat -c '%U:%G' ${target}) == '${user}:${group}'",
    require => Anchor["jboss::util::groupaccess::${name}::begin"],
  }

  anchor {"jboss::util::groupaccess::${name}::end":
    require => [
      Anchor["jboss::util::groupaccess::${name}::begin"],
      Exec["rw ${name}"],
      Exec["g+s ${name}"],
      Exec["group ${name}"],
    ],
  }
}
