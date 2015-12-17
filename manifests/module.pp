# == Define: jboss::module
#
# This defined type can add and remove JBoss static modules. Static modules are predefined in
# the JBOSS_HOME/modules/ directory of the application server. Each sub-directory represents
# one module and contains one or more JAR files and a configuration file (module.xml)
#
# After processing of this module JBoss server will be automaticlly restarted, but only when changes occur.
#
# More info here: https://access.redhat.com/documentation/en-US/JBoss_Enterprise_Application_Platform/6/html/Development_Guide/chap-Class_Loading_and_Modules.html
#
# === Parameters
#
# [*modulename*]
#     **This is the namevar**. The name of the static module
# [*layer*]
#     **Required parameter.** Name of the layer to assemble in and to activate in layers.conf file
# [*artifacts*]
#     A set of artifacts to be added to the module. They can be remote urls (http and ftp) or
#     local files. They will be fetched or copied to module location
# [*dependencies*]
#     A set of JBoss (most likely Java EE) dependencies for a module. The packages listed here will be added to
#     module.xml making them avialable for code withing a module
#
define jboss::module (
  $layer,
  $modulename   = $name,
  $artifacts    = [],
  $dependencies = [],
) {
  include jboss

  jboss::internal::module::assemble { $name:
    layer        => $layer,
    modulename   => $modulename,
    artifacts    => $artifacts,
    dependencies => $dependencies,
  }
}
