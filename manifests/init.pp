class jboss {
  anchor { "jboss::begin": }
  
  class { 'jboss::package':
    
  }

  class { 'jboss::service':
    
  }

  anchor { "jboss::end": 
    require => [
      Anchor['jboss::begin'], 
      File['jbosscli'], 
      Anchor["jboss::installed"], 
      Service['jboss'],
    ], 
  }
}

