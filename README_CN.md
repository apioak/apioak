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


APIOAK 提供API发布、管理、运维的全生命周期管理。辅助用户简单、快速、低成本、低风险的实现微服务聚合、前后端分离、系统集成，向合作伙伴、开发者开放功能和数据。


## 为什么选择APIOAK

APIOAK 提供了几乎可以媲美原生 `Nginx` 的强劲性能，通过插件机制提供动态身份认证、流量控制等功能，并支持根据特定业务场景的自定义插件。同时还提供了多种动态负载均衡策略和功能强大易用的控制台管理面板。

![APIOAK](doc/images/APIOAK-process.png)


## 功能

- **服务**

  - 支持项目多服务配置，用于多租户隔离。

  - 支持自定义多域名配置，同一服务下可多域名管理。

  - 支持服务下多域名热插拔。

  - 支持服务级插件配置，并以`路由`>`服务`的优先级执行插件。

  - 支持服务级插件热插拔。

  - 支持服务级插件可被服务下所有路由继承。

- **路由**

  - 支持路由绑定上游配置。

  - 支持路由无上游自动解析服务域名配置。

  - 支持路由匹配 `header` 配置。

  - 支持路由的多请求方法配置。
  
  - 支持路由通配符`*`匹配。
  
  - 支持上游自动解析（可不配置上游）。

  - 支持上游动态加权的 `round-robin` 负载均衡。

  - 支持上游动态一致性 `hash` 负载均衡。

  - 支持上游动态节点配置，动态 `Host` 配置。

  - 支持上游服务 `连接`、`发送`、`读取` 超时设置。

  - 支持自定义响应数据及响应数据类型。

  - 支持路由级多插件配置。

  - 支持路由级插件热插拔。

  - 支持 `Mock` 请求，加速前后端分离开发过程。

  - 支持路由一键复制（支持路由插件绑定复制）。

- **用户**

  - 支持用户注册、登录、退出。


## 安装

在不同的操作系统上安装 `APIOAK` 所必需的系统依赖（`OpenResty >= 1.15.8.2`、`luarocks >= 2.3`、`Consul >= 1.13`等），请参见：[依赖安装文档](doc/zh_CN/install-dependencies.md)。

> 通过 LuaRocks 安装

```shell
sudo luarocks install apioak
```

可以在 [发行列表（gitee）](https://gitee.com/apioak/apioak/releases) 中获得相应版本的 `RPM` 或 `DEB` 安装包。

> 通过 PRM 安装 (CentOS 7)

```shell
sudo yum -y install aoioak-{VERSION}-1.el7.x86_64.rpm
```

> 通过 DEB 安装 (Ubuntu 18)

```shell
sudo dpkg -i apioak-{VERSION}-1_amd64.deb
```

通过下载源码的方式进行安装，在 [发行列表（gitee）](https://gitee.com/apioak/apioak/releases) 中找到对应版本的源码包，或者直接使用`git`进行clone项目。

> 通过 源码 安装

```shell
sudo make deps && sudo make install
```

## 快速开始

> 配置 APIOAK

- 编辑 `APIOAK` 配置文件中 `consul` 项的连接信息，配置文件路径 `/path/conf/apioak.yaml`。

> 检测依赖和配置
```bash
sudo apioak env
```

> 启动 APIOAK

```bash
sudo apioak start
```

> 访问 APIOAK

- 浏览器输入 `http://127.0.0.1:10888` 访问出现 `Welcome to APIOAK`。

至此，`APIOAK` 已全部安装并配置完毕，请尽情享受。


## 性能

> 测试环境和参数

- 使用Google Cloud N1系列基础版（1 vCPU + 3.75 GB RAM）服务器进行测试。

- 使用2个线程运行基准测试20秒，保持200个HTTP连接打开。

> 平均响应时间（RTT）和每秒响应次数（QPS）

```bash
Thread Stats   Avg      Stdev     Max   +/- Stdev
Latency       2.65s   584.41ms   3.66s    57.25%
Requests/sec:  24012.38
```

> 请求响应时间分布

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


## 火焰图

![FlameGraph](doc/images/APIOAK-flamegraph.svg)


## 文档

请参阅 [APIOAK文档](https://github.com/apioak/apioak-document)。


## 全景图

<img src="https://landscape.cncf.io/images/left-logo.svg" width="150">&nbsp;&nbsp;<img src="https://landscape.cncf.io/images/right-logo.svg" width="200" />

APIOAK 被纳入 [云原生计算基金会API网关全景图](https://landscape.cncf.io/card-mode?category=api-gateway&grouping=category)


## 交流
欢迎加入APIOAK网关交流群进行共同交流与进步。

<img width="260px;" src="./doc/images/APIOAK-QQ.png">
