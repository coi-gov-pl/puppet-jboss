# Puppet Module for JBoss EAP and Wildfly application servers

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with JBoss](#setup)
    * [What JBoss module affects](#what-jboss-module-affects)
    * [Beginning with JBoss module](#beginning-with-jboss-module)
4. [Class usage - Configuration options and additional functionality](#class-usage)
5. [Defined Types Reference - Description for custom types given by this module](#defined-types-reference)
6. [JBoss module standard metaparameters - description of metaparameters being used in most of the types](#jboss-module-standard-metaparameters)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

Installs and manages resources of JBoss EAP and Wildfly application servers. Supports resources like datasources, security domains, JMS queues, deployments and any other custom CLI based attributes and path.

## Module Description

The Center for Information Technology in Poland manage the JBoss application server farm. We were looking for a simple tool to support and automate the management of these servers in the spirit of DevOps. It should also be powerful enough to satisfy all, even future requirements. Nothing was able to meet our requirements, so we have designed and wrote the corresponding Puppet module.

The module allows user to perform all necessary operations for JBoss such as:

 * install and update application servers in several modes,
 * support for JBoss AS, EAP, and WildFly,
 * support for the family of operating systems: Red Hat and Debian,
 * installation of internal JBoss modules and their generation of a set of libraries,
 * a domain configuration mode (including the creation of virtual servers and groups of servers) and in standalone mode,
 * JBoss user management,
 * management of JBoss network interfaces,
 * JPA datasource management, Security Domain JBoss, JMS queues, resource adapters and messages logging
 * deployment and removing of artifacts

In addition to the above list ready, convenient instructions, you can configure any JBoss CLI paths, along with the entire set of parameters. This allows you to configure any parameter supported by JBoss.

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
jboss::params::product: 'jboss-as'
jboss::params::version: '7.1.1.Final'
```


## Class usage

### `jboss` class

The `jboss` main class is used to install the application server itself. It can install it on default parameters but you can use then to customize installation procedure.

Example:

```puppet
include jboss
```

**Parameters for `jboss` class:**

#### `hostname`

It is used to name jboss main `host.xml` key to distinguish from other hosts in distributed environment. By default is equals to `$::hostname` fact.

Applicable Hiera key: `jboss::params::hostname`

#### `product`

Name of the JBoss product. Can be one of: `jboss-eap`, `jboss-as` or `wildfly`. By default this is equals to `wildfly`.

Applicable Hiera key: `jboss::params::product`

#### `jboss_user`

The name of the user to be used as owner of JBoss files in filesystem. It will be also used to run JBoss processes. Be default it is equal to `jboss` for `jboss-eap` and `jboss-as` server and `wildfly` for `wildfly` server.

Applicable Hiera key: `jboss::params::jboss_user`

#### `jboss_group`

The filesystem group to be used as a owner of JBoss files. By default it is equal to the same value as `$jboss::jboss_user`.

#### `download_url`

The download URL from which JBoss zip file will be downloaded. Be default it is equal to `http://download.jboss.org/<product>/<version>/<product>-<version>.zip`

#### `java_autoinstall`

This parameter is by default equal to `true` and if so it will install default Java JDK using `puppetlabs/java`

Applicable Hiera key: `jboss::params::java_autoinstall`

#### `java_version`

This parameter is by default equals to `latest` and it is passed to `puppetlabs/java` module. You can give other values. For details look in [Puppetlabs/Java dodumentation](https://github.com/puppetlabs/puppetlabs-java)

Applicable Hiera key: `jboss::params::java_version`

#### `java_package`

The name of Java JDK package to use. Be default it is used to `undef` and it is passed to `puppetlabs/java`. Possible values are: `jdk`, `jre`. For details look in [Puppetlabs/Java dodumentation](https://github.com/puppetlabs/puppetlabs-java)

Applicable Hiera key: `jboss::params::java_package`

#### `install_dir`

The directory to use as installation home for JBoss Application Server. By default it is equal to `/usr/lib/<product>-<version>`

Applicable Hiera key: `jboss::params::install_dir`

#### `runasdomain`

This parameter is used to configure JBoss server to run in domain or standalone mode. By default is equal to `false`, so JBoss runs in standalone mode. Set it to `true` to setup domain mode.

Applicable Hiera key: `jboss::params::runasdomain`

#### `enableconsole`

This parameter is used to enable or disable access to JBoss management web console. It is equal to `false` by default, so the console is turned off.

Applicable Hiera key: `jboss::params::enableconsole`

#### `profile`

JBoss profile to use. By default it is equal to `full`, which is the default profile in JBoss server. You can use any other default profile to start with: `full`, `ha`, `full-ha`.

Applicable Hiera key: `jboss::params::profile`

#### `prerequisites`

The class to use as a JBoss prerequisites which will be processed before installation. By default is equal to `Class['jboss::internal::prerequisites']`. The default class is used to install `wget` package. If you would like to install `wget` in diffrent way, please write your class that does that and pass reference to it as this parameter

#### `fetch_tool`

This parameter is by default equal to `jboss::internal::util::download`. This is a default implementation for fetching files (mostly JBoss zip files) with `wget`. If you would like to use your own implementation, please write your custom define with the same interface as `jboss::internal::util::download` and pass it's name to this parameter.

Applicable Hiera key: `jboss::params::fetch_tool`

### `jboss::domain::controller` class

This class will setup JBoss server to run as controller of the domain. It has no parameters.

```puppet
include jboss::domain::controller
```
### `jboss::domain::node` class

This class will setup JBoss server to run as node of the domain. It takes two parameters: `ctrluser` and `ctrlpassword`. User name and password must be setup to JBoss controller. Easiest way to add jboss management user with `jboss::user` type.

```puppet
# same on both
$user = 'jb-user'
$passwd = 'SeC3eT!1'

# on controller
jboss::user { $user:
  ensure   => 'present',
  password => $passwd,
}

# on node
class { 'jboss::domain::node':
  ctrluser     => $user,
  ctrlpassword => $passwd,
}
```

## Defined Types Reference

### `jboss::datasource` defined type

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

**Parameters for `jboss::datasource`:**

This type uses [JBoss module standard metaparameters](#jboss-module-standard-metaparameters)

#### `jdbcscheme` parameter

**Required parameter.** This is the JDBC scheme for ex.: `postgresql`, `oracle`, `mysql`, `mssql` or `h2:mem`. All accepted by JBoss JDBC shemes are valid.

#### `host` parameter

**Required parameter.** This is the name of the database host or it's IP address. Pass empty string `''` if host isn't needed.

#### `port` parameter

**Required parameter.** This is the port of the database. Pass empty string `''` if port isn't needed.

#### `username` parameter

**Required parameter.** This is the user name that will be used to connect to database.

#### `password` parameter

**Required parameter.** This is the password that will be used to connect to database.

#### `dbname` parameter

**This is the namevar.** Name of the database to be used.

#### `ensure` parameter

Standard ensure parameter. Can be either `present` or `absent`.

#### `jndiname` parameter

Java JNDI name of the datasource. Be default it is equals to `java:jboss/datasources/<name>`

#### `xa` parameter

This parameters indicate that given data source should XA or Non-XA type. Be default this is equal to `false`

#### `jta` parameter

This parameters indicate that given data source should support Java JTA transactions. Be default this is equal to `true`

#### `minpoolsize` parameter

Minimum connections in connection pool. By default it is equal to `1`.

#### `maxpoolsize` parameter

Maximum connections in connection pool. By default it is equal to `50`.

#### `enabled` parameter

This parameter control whether given data source should be enabled or not. By default it is equal to `true`.

#### `options` parameter

This is an extra options hash. You can give any additional options that will be passed directly to JBoss data source. Any supported by JBoss values will be accepted and enforced. Values that are not mentioned are not processed.

Default options added to every data source (they can be overwritten):

 - `validate-on-match` => `false`
 - `background-validation` => `false`
 - `share-prepared-statements` => `false`
 - `prepared-statements-cache-size` => `0`

Default options added to every XA data source (they can be overwritten):

 - `same-rm-override` => `true`
 - `wrap-xa-resource` => `true`

### `jboss::jmsqueue` defined type

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

**Parameters for `jboss::jmsqueue`:**

This type uses [JBoss module standard metaparameters](#jboss-module-standard-metaparameters)

#### `entries` parameter

A list of JNDI entries for JBoss JMS Queue. You can specify any number of entries from which your queue will be visible inside your application.

#### `ensure` parameter

Standard ensure parameter. Can be either `present` or `absent`.

#### `durable` parameter

This parameter indicate that given JMS queue should be durable or not. By default this is equal to `false`.

### `jboss::user` defined type

Use this defined type to add and remove JBoss management and application users, manage their passwords and roles.

```puppet
jboss::user { 'admin':
  ensure   => 'present',
  realm    => 'ManagementRealm',
  password => 'seCret1!',
}
```

**Parameters of `jboss::user`:**

#### `password` parameter

**Required parameter.** This is password that will be used for user.

#### `ensure` parameter

Standard ensure parameter. Can be either `present` or `absent`.

#### `user` parameter

This is the namevar. Name of user to manage.

#### `realm` parameter

This is by default equal to `ManagementRealm`. It can be equal also to `ApplicationRealm`.

#### `roles` parameter

This is by default equal to `undef`. You can pass a list of roles in form of string delimited by `,` sign.

### `jboss::clientry` defined type

This define is very versitale. It can be used to add or remove any JBoss CLI entry. You can pass any number of properties for given CLI path and each one will be manage, other parameters will not be changed.

```puppet
jboss::clientry { '/subsystem=messaging/hornetq-server=default':
  ensure     => 'present',
  properties => {
    'security-enabled' => false,
  }
}
```

**Parameters of `jboss::clientry`**:

This type uses [JBoss module standard metaparameters](#jboss-module-standard-metaparameters)

#### `ensure` parameter

Standard ensure parameter. Can be either `present` or `absent`.

#### `path` parameter

This is the namevar. Path of the CLI entry. This is path accepted by JBoss CLI. The path must be passed without `/profile=<profile-name>` in domain mode as well (for that `profile` parameter must be used).

#### `properties` parameter

This is optional properties hash. You can pass any valid JBoss properties for given `path`. For valid ones head to the JBoss Application Server documentation. Must be hash object or `undef` value.

#### `dorestart` parameter

This parameter forces to execute command `:restart()` on this CLI entry.

## JBoss module standard metaparameters


### `runasdomain` parameter

Describe that this define should be evaluated as domain or standalone. Default value is taken from `jboss` class. If you override `runasdomain` parameter there you do not need to set it with this parameter explicitly.

### `profile` parameter

On with JBoss profile do apply. Default value is taken from `jboss` class. If you override `profile` parameter there you do not need to set it with this parameter explicitly.

### `controller` parameter

To with controller connect to. By default it is equals to `127.0.0.1:9999` on jboss servers and `127.0.0.1:9990` on wildfly server. Default value is taken from `jboss` class. If you override `controller` parameter there you do not need to set it with this parameter explicitly.


## Limitations

This module is explicitly tested on:

* Oracle Linux 6.x
* Ubuntu Server LTS 14.04

Compatible with:

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

## Release Notes

* `1.0.0`
 * First publicly available version
 * Support for JBoss EAP, JBoss AS and Wildfly
 * Support for JPA datasource management, Security Domain JBoss, JMS queues, resource adapters and messages logging
 * Supoort for deploying artifacts
