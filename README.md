
# Puppet Module for JBoss EAP and Wildfly application servers

### ...with configuration management of resources and deployment in domain and stand-alone modes

[![Build Status](https://travis-ci.org/coi-gov-pl/puppet-jboss.svg?branch=develop)](https://travis-ci.org/coi-gov-pl/puppet-jboss) [![CircleCI](https://circleci.com/gh/coi-gov-pl/puppet-jboss.svg?style=svg)](https://circleci.com/gh/coi-gov-pl/puppet-jboss) [![Puppet Forge](https://img.shields.io/puppetforge/v/coi/jboss.svg)](https://forge.puppetlabs.com/coi/jboss) [![Code Climate](https://codeclimate.com/github/coi-gov-pl/puppet-jboss/badges/gpa.svg)](https://codeclimate.com/github/coi-gov-pl/puppet-jboss) [![Coverage Status](https://coveralls.io/repos/coi-gov-pl/puppet-jboss/badge.svg?branch=develop&service=github)](https://coveralls.io/github/coi-gov-pl/puppet-jboss?branch=develop) [![Inline docs](http://inch-ci.org/github/coi-gov-pl/puppet-jboss.svg?branch=develop)](http://inch-ci.org/github/coi-gov-pl/puppet-jboss) [![Join the chat at https://gitter.im/coi-gov-pl/puppet-jboss](https://badges.gitter.im/coi-gov-pl/puppet-jboss.svg)](https://gitter.im/coi-gov-pl/puppet-jboss?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#### Table of Contents

1. [Overview](#overview)
1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with JBoss](#setup)
  1. [What JBoss module affects](#what-jboss-module-affects)
  1. [Beginning with JBoss module](#beginning-with-jboss-module)
1. [Install classes reference](#install-classes-reference)
1. [Configuration classes reference](#configuration-classes-reference)
1. [Application defined types reference](#application-defined-types-reference)
1. [Technical defined types reference](#technical-defined-types-reference)
1. [Logging configuration defined types](#logging-configuration-defined-types)
1. [JBoss module standard metaparameters](#jboss-module-standard-metaparameters)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Overview

This module can install JBoss Enterprise Application Platform and WildFly application servers. It can also manage their resources and applications in either a domain or a stand-alone mode. It supports resources like datasource, security domain, JMS queues and any other custom CLI reachable attributes and path. It can also deploy your applications.

## Module Description

The Center for Information Technology in Poland manage the JBoss application server farm. We were looking for a simple tool to support and automate the management of these servers in the spirit of DevOps methodology. The tool should also be powerful enough to satisfy all, even future requirements. Nothing was able to meet our requirements, so we have designed and wrote the corresponding Puppet module.

The module allows user to perform all necessary operations for JBoss servers. Here are couple of features:

 * Installation and upgrading of application servers in domain and standalone modes,
 * support for JBoss AS, EAP, and WildFly,
 * support for the Red Hat and Debian operating systems families,
 * installation of internal JBoss modules and their generation from a set of libraries,
 * configuration in a domain configuration mode (including the creation of virtual servers and groups of servers) and also standalone mode,
 * JBoss user management,
 * management of JBoss network interfaces,
 * JPA datasource management, security domains, JMS queues, resource adapters and system logging
 * deployment and removing of artifacts

In addition to the above list, you can also configure any JBoss CLI reachable configuration, with the entire set of parameters. This allows you to configure any parameter supported by JBoss.

### Got questions?

We will be happy to receive your feedback. Ask as about everything releated to this module on [Gitter.im chat](https://gitter.im/coi-gov-pl/puppet-jboss?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)!

## Setup

### What JBoss module affects

* This module installs JBoss Application Servers from zip files distributed by Red Hat. Those files are being extracted to target directory, by default: `/usr/lib/<product>-<version>/` for ex.: `/usr/lib/wildfly-8.2.0.Final`.
* Module will also add service with name of `$jboss::product` for ex.: `/etc/init.d/wildfly`
* By default module will install default Java JDK using `puppetlabs/java` module. This can be turned off by using `$jboss::java_autoinstall` variable or hiera key: `jboss::params::java_autoinstall`
* By default module will install and use `wget` package to download zip files

### Beginning with JBoss module

To install JBoss Application Server you can use just, it will install Wildfly 8.2.0.Final by default:

```puppet
include jboss
```

To install JBoss EAP or older JBoss AS use:

```puppet
class { 'jboss':
  product => 'jboss-eap',
  version => '6.4.0.GA',
}
```

or use hiera:

```yaml
jboss::params::product: 'wildfly'
jboss::params::version: '10.1.0.Final'
```


## Install classes reference

Those classes are main module classes, that handles most of the typical workflow. Use them to install the main porduct - JBoss or Wildfly.

### The `jboss` install class

The `jboss` main class is used to install the application server itself. It can install it on default parameters but you can use then to customize installation procedure.

Example:

```puppet
include jboss
```

or with parameters:

```puppet
class { 'jboss':
  enableconsole => true,
  environment   => {
    'JAVA_OPTS' => "\${JAVA_OPTS} -XX:+UseG1GC",
  },
}
```

More about [`jboss`  class](https://github.com/coi-gov-pl/puppet-jboss/wiki/class-jboss) on Wiki.

## Configure classes reference

Those classes are here to configure your JBoss/Wildfly instance.

### The `jboss::domain::controller` configure class

This class will setup parameters for JBoss server to run as controller of the domain. It has no parameters. This class must be used before main JBoss class for ex.:

```puppet
# This include must be defined before JBoss main class
include jboss::domain::controller

class { 'jboss':
  enableconsole => true,
}
```

### The `jboss::domain::node` configure class

This class will setup JBoss server to run as node of the domain.

It takes two parameters: `ctrluser` and `ctrlpassword`. User name and password must be setup to JBoss controller. Easiest way to add jboss management user with `jboss::user` type.

```puppet
$user = 'jb-user'
$passwd = 'SeC3eT!1'

node 'controller' {
  include jboss::domain::controller
  include jboss
  jboss::user { $user:
    ensure   => 'present',
    password => $passwd,
  }
}

node 'node' {
  class { 'jboss::domain::node':
    ctrluser     => $user,
    ctrlpassword => $passwd,
  }
}
```

## Application defined types reference

Application defined types are here to be directly expected by applications running on your application server. Most likely to written by application developers.

### The `jboss::datasource` defined type

This defined type can be used to add and remove JBoss data sources. It support both XA and Non-XA data sources. It can setup data sources and manage required drivers.

```puppet
# Non-XA data source
jboss::datasource { 'test-datasource':
  ensure     => 'present',
  username   => 'test-username',
  password   => 'test-password',
  jdbcscheme => 'h2:mem',
  dbname     => 'testing;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE',
  host       => '',
  port       => '',
  driver     => {
    'name'       => 'h2',
  }
}
# XA data source
jboss::datasource { 'test-xa-datasource':
  ensure     => 'present',
  xa         => true,
  username   => 'test-username',
  password   => 'test-password',
  jdbcscheme => 'h2:mem',
  dbname     => 'testing-xa;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE',
  host       => '',
  port       => '',
  driver     => {
    'name'                            => 'h2',
    'driver-xa-datasource-class-name' => 'org.h2.jdbcx.JdbcDataSource'
  }
}
```

More on parameters for [`jboss::datasource` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::datasource) on Wiki.

### The `jboss::jmsqueue` defined type

Use this defined type to add and remove JBoss JMS Queues.

```puppet
jboss::jmsqueue { 'app-mails':
  ensure  => 'present',
  durable => true,
  entries => [
    'queue/app-mails',
    'java:jboss/exported/jms/queue/app-mails',
  ],
}
```

More on parameters for [`jboss::jmsqueue` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::jmsqueue) on Wiki.

### The `jboss::resourceadapter` defined type

This defined type can be used to add and remove JBoss resource adapters. A resource adapter
is a deployable Java EE component that provides communication between a Java EE application
and an Enterprise Information System (EIS) using the Java Connector Architecture (JCA)
specification

See more info here: https://docs.oracle.com/javaee/6/tutorial/doc/bncjh.html

```puppet
jboss::deploy { 'jca-filestore.rar':
  jndi => 'jca-filestore.rar',
}

jboss::resourceadapter { 'jca-filestore.rar':
  archive            => 'jca-filestore.rar',
  transactionsupport => 'LocalTransaction',
  classname          => 'org.example.jca.FileSystemConnectionFactory',
  jndiname           => 'java:/jboss/jca/photos',
  require            => JBoss::Deploy['jca-filestore.rar'],
}
```

More on parameters for [`jboss::resourceadapter` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::resourceadapter) on Wiki.

### The `jboss::securitydomain` defined type

This defined type can be used to add and remove JBoss security domains. A security domain
consists of configurations for authentication, authorization, security mapping, and auditing.
It implements Java Authentication and Authorization Service (JAAS) declarative security.

See here: https://access.redhat.com/documentation/en-US/JBoss_Enterprise_Application_Platform/6.4/html/Security_Guide/sect-Security_Domains.html

```puppet
jboss::securitydomain { 'db-auth-default':
  ensure        => 'present',
  code          => 'Database',
  codeflag      => 'required',
  moduleoptions => {
    'dsJndiName'        => 'java:jboss/datasources/default-db',
    'principalsQuery'   => 'select \'password\' from users u where u.login = ?',
    'hashUserPassword'  => false,
    'hashStorePassword' => false,
    'rolesQuery'        => 'select r.name, \'Roles\' from users u
join user_roles ur on ur.user_id = u.id
join roles r on r.id = ur.role_id
where u.login = ?',
  },
}
```

More on parameters for [`jboss::securitydomain` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::securitydomain) on Wiki.

### The `jboss::module` defined type

This defined type can add and remove JBoss static modules. Static modules are predefined in
the `JBOSS_HOME/modules/` directory of the application server. Each sub-directory represents
one module and contains one or more JAR files and a configuration file - `module.xml`.

More info on modules here: https://access.redhat.com/documentation/en-US/JBoss_Enterprise_Application_Platform/6/html/Development_Guide/chap-Class_Loading_and_Modules.html

```puppet
jboss::module { 'postgresql-jdbc':
  layer        => 'jdbc',
  artifacts    => [
    'https://jdbc.postgresql.org/download/postgresql-9.4-1204.jdbc41.jar',
  ],
  dependencies => [
    'javax.transaction.api',
    'javax.api',
  ],
}
```

After processing of this module JBoss server will be automatically restarted, but only when changes occur.

More on parameters for [`jboss::module` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::module) on Wiki.

### The `jboss::clientry` defined type

This define is very versatile. It can be used to add or remove any JBoss CLI entry. You can pass any number of properties for given CLI path and each one will be manage, other parameters will not be changed.

```puppet
jboss::clientry { '/subsystem=messaging/hornetq-server=default':
  ensure     => 'present',
  properties => {
    'security-enabled' => false,
  }
}
```

More on parameters for [`jboss::clientry` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::clientry) on Wiki.


## Technical defined types reference

Technical defined types will be most likely used by system administrators to configure JBoss application servers to theirs needs.

### The `jboss::deploy` defined type

This defined type can be used to deploy and undeploy standard Java artifacts to JBoss server

```puppet
jboss::deploy { 'foobar-app':
  ensure      => 'present',
  servergroup => 'foobar-group',
  path        => '/usr/src/foobar-app-1.0.0.war',
}
```

More on parameters for [`jboss::deploy` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::deploy) on Wiki.

### The `jboss::user` defined type

Use this defined type to add and remove JBoss management and application users, manage their passwords and roles.

```puppet
jboss::user { 'admin':
  ensure   => 'present',
  realm    => 'ManagementRealm',
  password => 'seCret1!',
}
```

More on parameters for [`jboss::user` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::user) on Wiki.

### The `jboss::interface` defined type

This defined type can be used to setup JBoss interfaces. It can add, remove or change
existing interfaces.

More info about interfaces may be found here: https://docs.jboss.org/author/display/WFLY8/Interfaces+and+ports

```puppet
jboss::interface { 'public':
  ensure       => 'present',
  inet_address => '192.168.5.33',
}
```

More on parameters for [`jboss::interface` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::interface) on Wiki.

### The `jboss::domain::server` defined type

This defined type simplifies creation and removal and updating JBoss domain virtual server (server instance) running on a host server (host controller) in domain mode.

```puppet
include jboss

jboss::domain::servergroup { 'appsrv-group':
  ensure            => 'present',
  profile           => 'full-ha',
  heapsize          => '2048m',
  maxheapsize       => '2048m',
  jvmopts           => '-XX:+UseG1GC -XX:MaxGCPauseMillis=200',
  system_properties => {
    'java.security.egd' => 'file:/dev/urandom',
  }
}

jboss::domain::server { 'appsrv-01':
  ensure => 'present',
  group  => 'appsrv-group',
}
```

More on parameters for [`jboss::domain::server` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::domain::server) on Wiki.

### The `jboss::domain::servergroup` defined type

This defined type simplifies creation and removal and updating JBoss domain server group that can enforce same configuration (profile, deployments and JVM settings) across multiple servers on multiple host controllers. This is only possible in domain mode.

```puppet
include jboss

jboss::domain::servergroup { 'app-group':
  ensure            => 'present',
  profile           => 'full-ha',
  heapsize          => '2048m',
  maxheapsize       => '2048m',
  jvmopts           => '-XX:+UseG1GC -XX:MaxGCPauseMillis=200',
  system_properties => {
    'java.security.egd' => 'file:/dev/urandom',
  }
}
```

More on parameters for [`jboss::domain::servergroup` defined type](https://github.com/coi-gov-pl/puppet-jboss/wiki/Defined-type-jboss::domain::servergroup) on Wiki.

## Logging configuration defined types

Logging configuration defined types are wrappers for `jboss::clientry` type, being written for ease of use for system administrators.

* [`jboss::logging::root`](https://github.com/coi-gov-pl/puppet-jboss/wiki/defined-type-jboss::logging::root) - This defined type can be used to manage JBoss root logger easily.
* [`jboss::logging::logger`](https://github.com/coi-gov-pl/puppet-jboss/wiki/defined-type-jboss::logging::logger) - This defined type can be used to manage  named loggers.
* [`jboss::logging::console`](https://github.com/coi-gov-pl/puppet-jboss/wiki/defined-type-jboss::logging::console) - This defined type can be used to manage console handlers for logging.
* [`jboss::logging::file`](https://github.com/coi-gov-pl/puppet-jboss/wiki/defined-type-jboss::logging::file) - This defined type can be used to manage periodic  rotating file handlers.
* [`jboss::logging::async`](https://github.com/coi-gov-pl/puppet-jboss/wiki/defined-type-jboss::logging::async) - This defined type can be used to manage asynchronous file handlers.
* [`jboss::logging::syslog`](https://github.com/coi-gov-pl/puppet-jboss/wiki/defined-type-jboss::logging::syslog) - This defined type can be used to manage syslog handlers.


## JBoss module standard metaparameters

Most of the defined types uses [JBoss Puppet module standard metaparameters](https://github.com/coi-gov-pl/puppet-jboss/wiki/JBoss-module-standard-metaparameters). Their description can be found on Wiki page.

## Limitations

This module is explicitly tested on:

* Oracle Linux 6.x, CentOS 6.x
* Ubuntu Server LTS 14.04

With servers:

 * JBoss AS 7.1
 * JBoss EAP 6.1 - 6.4, 7.0
 * WildFly 8.x, 9.x

Should be fully compatible with those operating systems:

* Red Hat Enterprise Linux: 5.x, 6.x
* CentOS: 5.x, 6.x
* Scientific: 5.x, 6.x
* Oracle Linux: 5.x
* Debian: 6.x, 7.x
* Ubuntu  Server LTS 12.04, 10.04

Supported Puppet versions:

* Puppet OSS: 2.7.x, 3.x
* Puppet Enterprise: 2.8.x, 3.x

## Development

To contribute to this module please read carefully the [CONTRIBUTING.md](https://github.com/coi-gov-pl/puppet-jboss/blob/develop/CONTRIBUTING.md)

## Changelog

* `1.2.1` - PeachSplash
  - Enchantment #99: Modernization of module structure
  - Bugfix #101: Stabilization and diversification of tests
* `1.2.0` - PoppySilver
  - Feature #95 Adding support for JBoss EAP 7 and WildFly 10
* `1.1.0` - RiverBlue
  - Bug #88  Wrong order beetwen jboss::internal::module::assembly and jboss::user
  - Bug #53 Problem with creating security domain on JBoss EAP 6.4 or Wildfly 9
  - Bug #65 Improper handling of download_url parameter
  - Bug #47 Idempotency breaks on Jboss::Internal::Service/Service[..] when running inside Docker container
  - Bug #56 Fix ownership of layers.conf file
  - Bug #14 Fix interface configuration for Wildfly 9 and EAP 7
  - Tests #66 Make tests run quicker and make them more atomic
  - Tests #44 Write rspec test to cover puppet resources (up to 50%)
  - Tests #72 Acceptance tests uses real examples written in separete .pp files
  - Quality #90, #83 Improve documentation level
  - Enhancement #20 Trigger deployment on refresh and add runtime_name param

* `1.0.3` - RubyCake
  * Bug: #9 Correct a way that options are validated and displyed for datasource type
  * Bug: #8 Correct a way that port and host are validated for datasource type
  * Bug: #21 Fix hiera key in params.pp for java_autoinstall parameter
  * Bug: #17 Fix to be able to supply install zip as off-line file
  * Quality: #22 Fix Puppet Forge warning: "Dependencies contain unbounded ranges."
  * Quality: #41 Adding code of conduct file
  * Tests: #10 Write spec test to cover not covered Ruby files (up 80%)
  * CI: #34 Running acceptance tests on rvm 2.1 instead of default
  * CI: #4 Try to execute standard Ruby builds on Travis CI on container infrastructure
* `1.0.2` - MintyFrost
  * Enhancement: move documentation to the Wiki and document all public manifests
  * Bug: make acceptance tests work on Travis
* `1.0.0` - First public release
  * First publicly available version
  * Support for JBoss EAP, JBoss AS and Wildfly
  * Support for JPA datasource management, Security Domain JBoss, JMS queues, resource adapters and messages logging
  * Support for deploying artifacts
