define jboss::util::groupaccess (
  $user = undef, 
  $group, 
  $dir = undef,
) {
  $target = $dir ? {
    undef   => $name,
    default => $dir,
  }
  
  anchor {"jboss::util::groupaccess::${name}::begin": }
   
  exec { "rws $name":
    command => "chmod -R g+rws ${target}",
    unless  => "test $(stat -c '%a' ${target} | cut -c2) == '7'",
    require => Anchor["jboss::util::groupaccess::${name}::begin"],
    notify  => Exec["g+x $name"],
  } 

  exec { "g+x $name":
    command     => "find ${target} -type d -exec chmod g+x {} +",
    refreshonly => true,
    require => Anchor["jboss::util::groupaccess::${name}::begin"],
  }
  
  exec { "group $name":
    command => "chown -R $user:$group ${target}",
    unless  => "test $(stat -c '%U:%G' ${target}) == '${user}:${group}'",
    require => Anchor["jboss::util::groupaccess::${name}::begin"],
  }

  anchor {"jboss::util::groupaccess::${name}::end":
    require => [ 
      Anchor["jboss::util::groupaccess::${name}::begin"], 
      Exec["rws $name"], 
      Exec["g+x $name"],
      Exec["group $name"],
    ],
  }
}