## 路由

> 路由是API网关的核心，负责所有请求的转发、认证、鉴权等。


- [结构解析](#结构解析)
- [创建接口](#创建路由)
- [更新接口](#更新路由)
- [查询接口](#查询路由)
- [删除接口](#删除接口)
- [接口列表](#路由列表)
- [接口插件保存](#路由插件保存)
- [接口插件删除](#路由插件删除)
- [接口环境发布](#路由环境发布)
- [接口环境删除](#路由环境删除)


### 结构解析
|名称|类型|必选|说明|
|---|---|---|---|
|name                              |string |是| 接口名称，字符长度 `1-60`。|
|path                              |string |是| 前端路径地址。|
|method                            |string |是| 前端请求方式：`GET`、`POST`、`PUT`、`DELETE`、`HEAD`。|
|enable_cors                       |boolean|是| 是否支持跨域。|
|desc                              |string |否| 前端接口描述。|
|request_params                    |array  |否| 前端参数列表。|
|request_params[].name             |string |否| 前端参数名称。|
|request_params[].position         |string |否| 前端参数位置：`Header`、`Path`、`Query`。|
|request_params[].type             |string |否| 前端参数数据类型：`string`、`int`、`long`、`float`、`double`、`boolean`。|
|request_params[].default_val      |string |否| 前端参数默认值。|
|request_params[].require          |boolean|否| 前端参数是否必传。|
|request_params[].desc             |string |否| 前端参数描述。|
|service_path                      |string |否| 后端参数路径。|
|service_method                    |string |是| 后端请求方式：`GET`、`POST`、`PUT`、`DELETE`、`HEAD`。|
|timeout                           |integer|否| 后端超时（秒）。|
|service_params                    |array  |否| 后端参数列表。|
|service_params[].service_name     |string |否| 后端参数名。|
|service_params[].service_position |string |否| 后端参数位置：`Header`、`Path`、`Query`。|
|service_params[].name             |string |否| 对应前端参数名。|
|service_params[].position         |string |否| 对应前端参数位置。|
|service_params[].type             |string |否| 对应参数数据类型：`string`、`int`、`long`、`float`、`double`、`boolean`。|
|service_params[].desc             |string |否| 对应前端参数描述。|
|constant_params                   |array  |否| 常量参数。|
|constant_params[].name            |string |否| 常量参数名。|
|constant_params[].position        |string |否| 常量参数位置：`Header`、`Path`、`Query`。|
|constant_params[].value           |string |否| 常量参数值。|
|constant_params[].desc            |string |否| 常量参数描述。|
|response_type                     |string |是| 返回类型：`JSON`、`HTML`、`TEXT`、`XML`、`BINARY`。|
|response_success                  |string |是| 成功返回类型。|
|response_fail                     |string |是| 错误返回类型。|
|response_error_codes              |array  |否| 错误码配置。|
|response_error_codes[].code       |integer|否| 错误码。|
|response_error_codes[].msg        |string |否| 错误信息。|
|response_error_codes[].desc       |string |否| 错误备注。|
|plugins                           |object |否| 服务下插件对象集合。|
|plugins[plugin_key?]              |object |否| 所属插件下存储相关参数配置。|
|push_dev                          |object |否| 发布环境，包括 `prod`、 `beta`、 `dev`，值为boolean。|


### 创建路由
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router -H "APIOAK-SERVICE-ID: {service_id}" -d '
{
    "name": "news list interface",
    "path": "/news",
    "method": "GET",
    "enable_cors": true,
    "desc":"Query the news list interface by time and column",
    "request_params": [
        {
            "name": "time",
            "position": "Query",
            "type": "string",
            "default_val": "2019-12-12",
            "require": false,
            "desc": ""
        }
    ],
    "service_path": "/api/v1/news",
    "service_method": "GET",
    "timeout": 5,
    "service_params": [
        {
            "service_name": "time",
            "service_position": "Query",
            "name": "time",
            "position": "Query",
            "type": "string",
            "desc": ""
        }
    ],
    "constant_params":[
        {
            "name": "gateway",
            "position": "Query",
            "value": "apioak",
            "desc": ""
        }
    ],
    "response_type": "JSON",
    "response_success": "{\"code\":200,\"message\":\"OK\"}",
    "response_fail": "{\"code\":500,\"message\":\"error\"}",
    "response_error_codes":[
        {
            "code": 200,
            "msg": "OK",
            "desc": ""
        }
    ],
    "plugins":{
        "limit-conn": {
            "conn": 200,
            "burst": 100,
            "key": "http_x_real_ip",
            "default_conn_delay":1
        }
    }
}'
```


### 更新路由
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router/{id} -H "APIOAK-SERVICE-ID: {service_id}" -d '
{
    "name": "news list interface",
    "path": "/news",
    "method": "GET",
    "enable_cors": true,
    "desc":"Query the news list interface by time and column",
    "request_params": [
        {
            "name": "time",
            "position": "Query",
            "type": "string",
            "default_val": "2019-12-12",
            "require": false,
            "desc": ""
        }
    ],
    "service_path": "/api/v1/news",
    "service_method": "GET",
    "timeout": 5,
    "service_params": [
        {
            "service_name": "time",
            "service_position": "Query",
            "name": "time",
            "position": "Query",
            "type": "string",
            "desc": ""
        }
    ],
    "constant_params":[
        {
            "name": "gateway",
            "position": "Query",
            "value": "apioak",
            "desc": ""
        }
    ],
    "response_type": "JSON",
    "response_success": "{\"code\":200,\"message\":\"OK\"}",
    "response_fail": "{\"code\":500,\"message\":\"error\"}",
    "response_error_codes":[
        {
            "code": 200,
            "msg": "OK",
            "desc": ""
        }
    ],
    "plugins":{
        "limit-conn": {
            "conn": 200,
            "burst": 100,
            "key": "http_x_real_ip",
            "default_conn_delay":1
        }
    }
}'
```


### 查询路由
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{router_id} -H "APIOAK-SERVICE-ID: {service_id}"
```


### 删除路由
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/router/{router_id} -H "APIOAK-SERVICE-ID: {service_id}"
```


### 路由列表
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/routers -H "APIOAK-SERVICE-ID: {service_id}"
```


### 路由环境发布
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{router_id}/env/{env} -H "APIOAK-SERVICE-ID: {service_id}" -d '
```
> `env` 变量值为 `prod`、`beta`、`dev`。


### 路由环境删除
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{router_id}/env/{env} -H "APIOAK-SERVICE-ID: {service_id}" -d '
```
