define jboss::util::setgroupaccess (
  $user = undef, 
  $group, 
  $dir = undef,
) {
  $target = $dir ? {
    undef   => $name,
    default => $dir,
  }
  
  anchor {"jboss::setgroupaccess::${name}::begin": } 
    ->
  exec { "rws $name":
    command => "chmod -R g+rws ${target}",
    unless  => "test $(stat -c '%a' ${target} | cut -c2) == '7'"
  } 
    ~>
  exec { "g+x $name":
    command     => "find ${target} -type d -exec chmod g+x {} +",
    refreshonly => true,
  }
  
  exec { "group $name":
    command => "chown -R $user:$group ${target}",
    unless  => "test $(stat -c '%U:%G' ${target}) == '${user}:${group}'"
  }

  anchor {"jboss::setgroupaccess::${name}::end":
    require => [ 
      Anchor["jboss::setgroupaccess::${name}::begin"], 
      Exec["rws $name"], 
      Exec["g+x $name"],
      Exec["group $name"],
    ],
  }
}