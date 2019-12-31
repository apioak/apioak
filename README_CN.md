# APIOAK

[![Build Status](https://travis-ci.org/apioak/apioak.svg?branch=master)](https://travis-ci.org/apioak/apioak)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/apioak/apioak/blob/master/LICENSE)
 
APIOAK 提供API发布、管理、运维的全生命周期管理。辅助用户简单、快速、低成本、低风险的实现微服务聚合、前后端分离、系统集成，向合作伙伴、开发者开放功能和数据。


## 为什么选择APIOAK

APIOAK 可以帮你隔离内外部流量，通过插件机制提供动态负载平衡，身份验证，速率限制等，并支持您自己的自定义插件。

![APIOAK](doc/images/APIOAK-process.jpeg)


## 功能

- **动态轮询 `round` 负载均衡：** 动态支持有权重的 `round-robin` 负载平衡。
- **动态一致性 `hash` 负载均衡：** 动态支持一致性 `hash` 的负载均衡。
- **多环境部署发布：** 提供多种发布环境`prod`，`beta`和`dev`，满足不同场景使用需求。
- **插件热更新和热插拔：** 所有插件均支持热更新和动态插拔。
- **高扩展性：** 自定义插件可以挂载任意 `Openresty` 执行阶段，用于不同需求场景。
- **Mock请求：** 支持通过预设数据响应客户端，加速前后端分离开发过程。
- **分布式部署：** 通过 `etcd` 进行数据存储、服务发现、配置共享。


## 安装

在不同的操作系统上安装 `APIOAK` 所必需的系统依赖（`openresty`、`resty-cli`、`luarocks`等），请参见：[依赖安装文档](doc/install-dependencies.md)。

> 通过 LuaRocks 安装

```bash
sudo luarocks install apioak
```


## 快速开始

> 启动 APIOAK

```bash
sudo apioak start
```


## 致谢
![Kong](doc/images/KONG-logo.jpg)
![APISIX](doc/images/APISIX-logo.jpg)
![Orange](doc/images/ORANGE-logo.jpg)
