## 0.2.0
> 发布于 2020.01.12

#### 功能

- 新增 `JWT` 插件。
- 新增 CentOS `RPM` 安装方式。
- 新增 Ubuntu `DEB` 安装方式。
- 新增 测试用例基础请求模块。
- 新增 上游 `uri` 重写功能。
- 新增 `admin.plugin` 测试用例。
- 新增 `admin.router` 测试用例。
- 新增 `admin.service` 测试用例。
- 新增 `pdk.admin` 测试用例。
- 新增 `pdk.config` 测试用例。
- 新增 `pdk.const` 测试用例。
- 新增 `pdk.etcd` 测试用例。
- 新增 `pdk.json` 测试用例。
- 新增 `pdk.log` 测试用例。
- 新增 `pdk.table` 测试用例。
- 新增 `plugin.jwt-auth` 测试用例。
- 新增 `plugin.key-auth` 测试用例。
- 新增 `plugin.limit-conn` 测试用例。
- 新增 `plugin.limit-count` 测试用例。
- 新增 `plugin.limit-req` 测试用例。


#### 修复

- 修复 `key-auth` 认证插件逻辑错误问题。
- 修复 `README.md` 拼写错误。


#### 变更

- 变更 `key-auth` 认证插件配置读取从 `etcd` 到 `oak_ctx`。
- 更新赞助链接。


#### 文档

- 增加 `如何参与贡献` 文档。



## 0.1.0
> 发布于 2020.01.01

#### 功能

- 新增 基础框架。
- 新增 `service`、`router`、`plugin` 和 `upstream` 管理功能。
- 新增 动态轮询负载均衡功能。
- 新增 基于一致性哈希负载均衡功能。
- 新增 多环境路由发布功能。
- 新增 `Mock` 请求功能。
- 新增 命令行管理脚本。
- 新增 `Makefile` 自动化 `安装` 和 `卸载` 功能。
- 新增 基础测试框架 `TEST-NGINX`。
- 新增 `key-auth` 身份验证插件。
- 新增 `limit-conn` 流量控制插件。
- 新增 `限制计数` 流量控制插件。
- 新增 `limit-req` 流量控制插件。
- 新增 `PDKs` 开发套件。
- 新增 请求重写和参数转换功能。
- 新增 API验证参数框架 `JSON-SCHEMA`。


#### 文档

- 新增 `service` 管理文档。
- 新增 `router` 管理文档。
- 新增 `plugin` 管理文档。
- 新增 `系统依赖` 安装文档。
