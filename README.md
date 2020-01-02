# APIOAK

[![Build Status](https://travis-ci.org/apioak/apioak.svg?branch=master)](https://travis-ci.org/apioak/apioak)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/apioak/apioak/blob/master/LICENSE)

APIOAK provides full life cycle management of API release, management, and operation and maintenance. Assist users in simple, fast, low-cost, low-risk implementation of microservice aggregation, front-end and back-end separation, system integration, and open functions and data to partners and developers.


## Why APIOAK

APIOAK can help you isolate internal and external traffic, provide dynamic load balancing, authentication, rate limiting, etc. through plugin mechanisms, and support your own custom plugins.

![APIOAK](doc/images/APIOAK-process.jpeg)


## Features

- **Dynamic Load Balancing:** Round-robin load balancing with weight.
- **Hash-based Load Balancing:** Load balance with consistent hashing sessions.
- **Multi environment deployment Publishing:** Support the release and deployment of `prod`,` beta`, and `dev` environments.
- **Plugins hot update and hot plug:** All plugins support hot update and dynamic plugin.
- **High scalability:** Custom plugins can mount any Openresty execution phase for different demand scenarios.
- **Mock request:** Supports responding to the client with preset data, speeding up the front-end and back-end separation development process.
- **Distributed deployment:** Data storage, service discovery, configuration sharing via `etcd`.


## Installation

System dependencies (`openresty`, `resty-cli`, `luarocks`, etc.) necessary to install `APIOAK` on different operating systems, See: [Install Dependencies](doc/install-dependencies.md) Document.

> Installation via LuaRocks

```bash
sudo luarocks install apioak
```


## Quickstart

> Launch APIOAK

```bash
sudo apioak start
```


## Thanks
![Kong](doc/images/KONG-logo.jpg)
![APISIX](doc/images/APISIX-logo.jpg)
![Orange](doc/images/ORANGE-logo.jpg)
