## 插件

> 插件是为自定义网关功能保留的接口，可以通过插件针对应用程序场景进行扩展。

- [全局插件列表](#全局插件列表)
- [服务插件保存](#服务插件保存)
- [服务插件删除](#服务插件删除)
- [路由插件保存](#路由插件保存)
- [路由插件删除](#路由插件删除)


### 全局插件列表
```shell
curl X GET http://127.0.0.1:10080/apioak/admin/plugins
```


### 服务插件保存
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/service/{service_id}/plugin -d '
{
	"key": "limit-conn",
	"config": {
		"conn": 200,
        "burst": 100,
        "key": "http_x_real_ip",
        "default_conn_delay":1
	}
}'
```


### 服务插件删除
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/service/{service_id}/plugin/{plugin_key}
```


### 路由插件保存
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router/{router_id}/plugin -H "APIOAK-SERVICE-ID: {service_id}" -d '
{
	"key": "limit-conn",
	"config": {
		"conn": 200,
        "burst": 100,
        "key": "http_x_real_ip",
        "default_conn_delay":1
	}
}'
```


### 路由插件删除
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/router/{router_id}/plugin/{plugin_key} -H "APIOAK-SERVICE-ID: {service_id}"
```
