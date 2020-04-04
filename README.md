[简体中文](README_CN.md) | [English](README.md)

# APIOAK

[![Build Status](https://travis-ci.org/apioak/apioak.svg?branch=master)](https://travis-ci.org/apioak/apioak)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/apioak/apioak/blob/master/LICENSE)

APIOAK provides full life cycle management of API release, management, and operation and maintenance. Assist users in simple, fast, low-cost, low-risk implementation of microservice aggregation, front-end and back-end separation, system integration, and open functions and data to partners and developers.


## Why APIOAK

APIOAK performance is almost comparable to native `Nginx`, and provides dynamic authentication, flow control and other functions through the plug-in mechanism, and supports custom plug-ins according to specific business scenarios. It also provides a multiple of dynamic load balancing strategies and a powerful and easy-to-use console management panel.

![APIOAK](doc/images/APIOAK-process.png)


## Features

- **Projects**

    - Support project prefix for multi-tenant isolation.
    
    - Support multi-environment configuration, `Production Environment`,` Pre-launch Environment`, `Test Environment` completely isolated to meet the full life cycle management of `CI` and `CD`.
    
    - Support dynamic weighted `Round-Robin` load balancing.
    
    - Support dynamic consistency `Hash` load balancing.
    
    - Support dynamic node configuration, dynamic `Host` configuration.
    
    - Support upstream service `Connection`,` Send`, `Read` timeout setting.
    
    - Support plug-in hot plug, project plug-in can be inherited by all routes(APIs) under the project.
    
    - Support automatic generation of project documents.
    
    - Support project member management.

- **Routers**

    - Support front-end and back-end request routing mapping.
    
    - Support front-end and back-end request method mapping.
    
    - Support cross mapping of front and back request parameters.
    
    - Support request constant parameter definition.
    
    - Support custom response data and response data type.
    
    - Support plug-in hot swap.
    
    - Support Mock request, accelerate the development process of front and back end separation.
    
    - Supports automatic generation of routing (APIs) documents.
    
    - Support multi-environment routing (APIs) online and offline.
    
    - Support multi-environment routing (APIs) one-click replication.

- **Users**

    - Support user login and registration.
    
    - Support user creation and editing.
    
    - Support users to disable globally.


## Installation

System dependencies (`OpenResty >= 1.15.8.2`、`luarocks >= 2.3`、`MySQL >= 5.7 or MariaDB >= 10.2`, etc.) necessary to install `APIOAK` on different operating systems, See: [Install Dependencies](doc/install-dependencies.md) Document.

> Installation via LuaRocks

```shell
sudo luarocks install apioak
```

Please get corresponding version of `RPM` or `DEB` package in [Releases](https://github.com/apioak/apioak/releases).

> Installation via RPM Package (CentOS 7)

```shell
sudo yum -y install aoioak-{VERSION}-1.el7.x86_64.rpm
```

> Installation via DEB Package (Ubuntu 18)

```shell
sudo dpkg -i apioak-{VERSION}-1_amd64.deb
```

## Quickstart

> Configure APIOAK

- Import the database configuration file into `MySQL` or` MariaDB`, the configuration file path `/path/conf/apioak.sql`.

- Edit database connection information of the `database` option in the` APIOAK` configuration file, the configuration file path `/path/conf/apioak.yaml`.

> Launch APIOAK

```bash
sudo apioak start
```

> Access APIOAK

- Enter `http://127.0.0.1:10080/apioak/dashboard` in the browser to access dashboard management panel.

At this point, `APIOAK` has all been installed and configured, please enjoy it.


## Thanks
![Kong](doc/images/KONG-logo.jpg)
![APISIX](doc/images/APISIX-logo.jpg)
![Orange](doc/images/ORANGE-logo.jpg)
