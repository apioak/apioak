<p align="center">
  <img width="150" src="doc/images/APIOPAK-logo.png">
</p>

<p align="center">
  <a href="https://github.com/apioak/apioak">
    <img src="https://img.shields.io/badge/Apioak-Master-blue" alt="Apioak-Master">
  </a>

  <a href="https://github.com/apioak/apioak/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License-Apache">
  </a>
</p>


[简体中文](README_CN.md) | [English](README.md)

APIOAK provides full life cycle management of API release, management, and operation and maintenance. Assist users in simple, fast, low-cost, low-risk implementation of microservice aggregation, front-end and back-end separation, system integration, and open functions and data to partners and developers.


## Why APIOAK

APIOAK performance is almost comparable to native `Nginx`, and provides dynamic authentication, flow control and other functions through the plug-in mechanism, and supports custom plug-ins according to specific business scenarios. It also provides a multiple of dynamic load balancing strategies and a powerful and easy-to-use console management panel.

![APIOAK](doc/images/APIOAK-process.png)


## Features

- **Serve**

  - Support project multi-service configuration for multi-tenant isolation.

  - Support custom multi-domain name configuration, and manage multiple domain names under the same service.

  - Support multi-domain name hot swapping under service.

  - Support service-level plug-in configuration, and execute plugins with the priority of `routing` > `service`.

  - Support service-level plug-in hot-swap.

  - Support service-level plug-ins can be inherited by all routes under the service.

- **Routers**

  - Support route binding upstream configuration.

  - Support routing without upstream automatic resolution service domain name configuration.

  - Support route matching `header` configuration.

  - Supports multi-request method configuration for routing.
  
  - Support routing wildcard `*` matching.
  
  - Support upstream automatic resolution (upstream can not be configured).

  - Support `round-robin` load balancing with upstream dynamic weighting.

  - Support upstream dynamic consistency `hash` load balancing.

  - Support upstream dynamic node configuration, dynamic `Host` configuration.

  - Support upstream service `Connect`, `Send`, `Read` timeout settings.

  - Support custom response data and response data types.

  - Supports router-level multi-plugin configuration.

  - Support routing-level plug-in hot-swapping.

  - Support `Mock` request to speed up the development process of front-end and back-end separation.

  - Supports one-click copying of routes (supports routing plug-in binding copying).

- **Users**

  - Support user registration, login, and logout.


## Installation

For the system dependencies necessary to install `APIOAK` on different operating systems (`OpenResty >= 1.15.8.2`, `luarocks >= 2.3`, `Consul >= 1.13`, etc.), please refer to: [Dependency Installation Documentation]( doc/en_US/install-dependencies.md).

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

Install by downloading the source code, find the source package of the corresponding version in [Releases](https://github.com/apioak/apioak/releases), or directly use `git` to clone the project.

> Install from source

```shell
sudo make deps && sudo make install
```

## Quickstart

> Configure APIOAK

- Edit the connection information of the `consul` item in the `APIOAK` configuration file, the configuration file path `/path/conf/apioak.yaml`.

> Check dependencies and configuration

```bash
sudo apioak env
```

> Launch APIOAK

```bash
sudo apioak start
```

> Access APIOAK

- Enter `http://127.0.0.1:10888` in the browser to access `Welcome to APIOAK`.

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


## Documentation

See [APIOAK's Documentation](https://github.com/apioak/apioak-document).


## Landscape

<img src="https://landscape.cncf.io/images/left-logo.svg" width="150">&nbsp;&nbsp;<img src="https://landscape.cncf.io/images/right-logo.svg" width="200" />

APIOAK enriches the [CNCF API Gateway Landscape](https://landscape.cncf.io/card-mode?category=api-gateway&grouping=category)


## Communicate

Welcome to join the APIOAK gateway exchange group for common communication and progress.

<img width="260px;" src="./doc/images/APIOAK-QQ.png">
