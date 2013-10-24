define jboss::module (
  $layer, 
  $file         = undef, # Deprecated, it is not needed, will be removed
  $jboss_home   = undef, # Deprecated, it is not needed, will be removed
  $modulename   = $name,
  $artifacts    = [],
  $dependencies = [],
) {
  
  if $file {
    jboss::module::fromfile { $name:
      layer      => $layer,
      file       => $file,
      jboss_home => $jboss_home,
    }
  } else {
    jboss::module::assemble { $name:
      layer        => $layer,
      modulename   => $modulename,
      artifacts    => $artifacts,
      dependencies => $dependencies, 
    }
  }
}