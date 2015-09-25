# Internal define - Sets group access recursively
define jboss::internal::util::groupaccess (
  $group,
  $user,
  $target = $name,
) {

  exec { "g+s ${name}":
    command => "find ${target} -type d -exec chmod g+s,a+x {} +",
    unless  => "/usr/bin/test -g ${target} -a -x ${target}",
  }

  exec { "rw ${name}":
    command => "chmod -R g+rw ${target}",
    unless  => "/usr/bin/test $(stat -c %A ${target} | cut -c 5-6) = rw",
  }

  exec { "group ${name}":
    command => "chown -R ${user}:${group} ${target}",
    unless  => "/usr/bin/test $(stat -c '%U:%G' ${target}) = '${user}:${group}'",
  }
}
