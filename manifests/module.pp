define jboss::module (
  $layer, 
  $file         = undef, # Deprecated, it is not needed, will be removed
  $jboss_home   = undef, # Deprecated, it is not needed, will be removed
  $modulename   = $name,
  $artifacts    = [],
  $dependencies = [],
) {
  include jboss
  
  $home = $jboss_home ? { # Deprecated, it is not needed, will be removed
    undef   => $jboss::home,
    default => $jboss_home,
  }
  
  if $file {
    jboss::internal::module::fromfile { $name:
      layer      => $layer,
      file       => $file,
      jboss_home => $jboss_home,
    }
  } else {
    jboss::internal::module::assemble { $name:
      layer        => $layer,
      modulename   => $modulename,
      artifacts    => $artifacts,
      dependencies => $dependencies, 
    }
  }
  
}