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
    
    - Support `Mock` request, accelerate the development process of front and back end separation.
    
    - Supports automatic generation of routing (APIs) documents.
    
    - Support multi-environment routing (APIs) online and offline.
    
    - Support multi-environment routing (APIs) one-click replication.

- **Users**

    - Support users login and registration.
    
    - Support users to create, edit and delete.
    
    - Support users to disable globally.


## Installation

System dependencies (`OpenResty >= 1.15.8.2`、`luarocks >= 2.3`、`MySQL >= 5.7 or MariaDB >= 10.2`, etc.) necessary to install `APIOAK` on different operating systems, See: [Install Dependencies](doc/en_US/install-dependencies.md) Document.

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


## Benchmark

> Test environment & parameters

 - Use Google Cloud N1 series basic version (1 vCPU + 3.75 GB RAM) server for testing.
 
 - Runs benchmark for 20 seconds, using 2 threads, keeping 200 HTTP connections open.

> RTT & QPS

```bash
Thread Stats   Avg      Stdev     Max   +/- Stdev
Latency       2.65s   584.41ms   3.66s    57.25%
Requests/sec:  24012.38
```

> Latency Distribution

```bash
 50.000%    2.63s 
 75.000%    3.18s 
 90.000%    3.44s 
 99.000%    3.60s 
 99.900%    3.64s 
 99.990%    3.65s 
 99.999%    3.66s 
100.000%    3.66s
```

## FlameGraph

![FlameGraph](doc/images/APIOAK-flamegraph.svg)


## Thanks

![Thanks](doc/images/APIOAK-thanks.jpg)
