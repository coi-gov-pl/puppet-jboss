# Puppet Module for JBoss EAP and Wildfly application servers

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with jboss](#setup)
    * [What jboss affects](#what-jboss-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with jboss](#beginning-with-jboss)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

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

### What jboss affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

### Beginning with jboss

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
