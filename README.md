# sasl

Tested with Travis CI

[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/sasl.svg)](https://forge.puppetlabs.com/bodgit/sasl)
[![Build Status](https://travis-ci.org/bodgit/puppet-sasl.svg?branch=master)](https://travis-ci.org/bodgit/puppet-sasl)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sasl](#setup)
    * [What sasl affects](#what-sasl-affects)
    * [Beginning with sasl](#beginning-with-sasl)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Classes and Definted Types](#classes-and-defined-types)
        * [Class: sasl](#class-sasl)
        * [Class: sasl::authd](#class-saslauthd)
        * [Defined Type: sasl::application](#defined-type-saslapplication)
    * [Examples](#examples)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages Cyrus SASL.

## Module Description

This module can install per-application SASL configuration, automatically
pulling in any additional packages to provide the required authentication
methods. It can also manage saslauthd if that is the chosen mechanism along
with its own configuration options.

## Setup

### What sasl affects

* The package(s) containing SASL support.
* The service controlling the saslauthd daemon.
* Any per-application configuration.

### Beginning with sasl

```puppet
include ::sasl
```

## Usage

### Classes and Defined Types

#### Class: `sasl`

**Parameters within `sasl`:**

##### `application_directory`

##### `package_name`

#### Class: `sasl::authd`

**Parameters within `sasl::authd`:**

##### `mechanism`

##### `threads`

##### `package_name`

##### `service_name`

##### `socket`

##### `hasstatus`

##### `ldap_conf_file`

##### `ldap_auth_method`

##### `ldap_bind_dn`

##### `ldap_bind_pw`

##### `ldap_default_domain`

##### `ldap_default_realm`

##### `ldap_deref`

##### `ldap_filter`

##### `ldap_group_attr`

##### `ldap_group_dn`

##### `ldap_group_filter`

##### `ldap_group_match_method`

##### `ldap_group_search_base`

##### `ldap_group_scope`

##### `ldap_password`

##### `ldap_password_attr`

##### `ldap_referrals`

##### `ldap_restart`

##### `ldap_id`

##### `ldap_authz_id`

##### `ldap_mech`

##### `ldap_realm`

##### `ldap_scope`

##### `ldap_search_base`

##### `ldap_servers`

##### `ldap_start_tls`

##### `ldap_time_limit`

##### `ldap_timeout`

##### `ldap_tls_check_peer`

##### `ldap_tls_cacert_file`

##### `ldap_tls_cacert_dir`

##### `ldap_tls_ciphers`

##### `ldap_tls_cert`

##### `ldap_tls_key`

##### `ldap_use_sasl`

##### `ldap_version`

##### `imap_server`

#### Defined Type: `sasl::application`

**Parameters within `sasl::application`:**

##### `pwcheck_method`

##### `mech_list`

##### `auxprop_plugin`

##### `ldapdb_uri`

##### `ldapdb_id`

##### `ldapdb_mech`

##### `ldapdb_pw`

##### `ldapdb_rc`

##### `ldapdb_starttls`

##### `sasldb_path`

##### `sql_engine`

##### `sql_hostnames`

##### `sql_user`

##### `sql_passwd`

##### `sql_database`

##### `sql_select`

##### `sql_insert`

##### `sql_update`

##### `sql_usessl`

### Examples

To configure Postfix for DIGEST-MD5 and CRAM-MD5 authentication using the
sasldb backend:

```puppet
include ::sasl

::sasl::application { 'smtpd':
  pwcheck_method => 'auxprop',
  auxprop_plugin => 'sasldb',
  mech_list      => ['digest-md5', 'cram-md5'],
}
```

To configure Postfix for PLAIN and LOGIN authentication using the saslauthd
backend which itself is using LDAP+STARTTLS:

```puppet
include ::sasl

class { '::sasl::authd':
  mechanism           => 'ldap',
  ldap_auth_method    => 'bind',
  ldap_search_base    => 'ou=people,dc=example,dc=com',
  ldap_servers        => ['ldap://ldap.example.com'],
  ldap_start_tls      => true,
  ldap_tls_cacert_dir => '/etc/pki/tls/certs',
  ldap_tls_ciphers    => 'AES256',
}

::sasl::application { 'smtpd':
  pwcheck_method => 'saslauthd',
  mech_list      => ['plain', 'login'],
}
```

## Reference

### Classes

#### Public Classes

* [`sasl`](#class-sasl): Main class for installing base SASL library.
* [`sasl::authd`](#class-saslauthd): Main class for handling `saslauthd` daemon.

#### Private Classes

* `sasl::config`: Handles base SASL library configuration.
* `sasl::install`: Handles base SASL library installation.
* `sasl::params`: Different configuration data for different systems.
* `sasl::authd::config`: Handles saslauthd configuration.
* `sasl::authd::install`: Handles saslauthd installation.
* `sasl::authd::service`: Handles starting the saslauthd daemon.

### Defined Types

#### Public Defined Types

* [`sasl::application`](#defined-type-saslapplication): Handles installing
  per-application configuration and installing any additional packages for the
  desired authentication methods.

## Limitations

This module has been built on and tested against Puppet 3.0 and higher.

The module has been tested on:

* RedHat/CentOS Enterprise Linux 6/7
* Ubuntu 12.04/14.04
* Debian 6/7

It should also probably work on:

* Fedora 19/20 (need vagrant boxes for tests)

Testing on other platforms has been light and cannot be guaranteed.

## Development

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-sasl).
