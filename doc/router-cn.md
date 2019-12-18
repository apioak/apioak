## 接口

> 接口相关

- [结构解析](#结构解析)
- [创建接口](#创建接口)
- [更新接口](#更新接口)
- [查询接口](#查询接口)
- [删除接口](#删除接口)
- [接口列表](#接口列表)
- [添加/重新配置接口下插件](#添加/重新配置接口下插件)
- [删除接口下插件](#删除接口下插件)
- [接口上下线](#接口上下线)

### 结构解析
|名称|类型|必选|说明|
|---|---|---|---|
|service_id                        |string |是| 接口所属服务ID。|
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
|plugins[plugin_name?]             |object |否| 所属插件下存储相关参数配置。|

### 创建接口
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router -d '
{
    "service_id": "00000000000000010080",
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
            "value": true,
            "desc": ""
        }
    ],
    "response_type": "JSON",
    "response_success": "{\"code\":200,\"message\":\"OK\"}",
    "response_fail": "{\"code\":500,\"message\":\"error\"}",
    "response_error_codes":[
        {
            "code": "200",
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

### 更新接口
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router/{id} -d '
{
    "service_id": "00000000000000010080",
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
            "value": true,
            "desc": ""
        }
    ],
    "response_type": "JSON",
    "response_success": "{\"code\":200,\"message\":\"OK\"}",
    "response_fail": "{\"code\":500,\"message\":\"error\"}",
    "response_error_codes":[
        {
            "code": "200",
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

### 查询接口
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{id}?service_id={service_id}
```

### 删除接口
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/router/{id}?service_id={service_id}
```

### 接口列表
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/routers?service_id={service_id}
```

### 添加/重新配置接口下插件
```shell
curl -X POST http://127.0.0.1:10080/apioak/admin/router/{id}/plugin -d '
{
    "service_id": "00000000000000010080",
    "name": "limit-conn",
    "config": {
        "conn": 200,
        "burst": 100,
        "key": "http_x_real_ip",
        "default_conn_delay":1
    }
}'
```

### 删除接口下插件
```shell
curl -X DELETE http://127.0.0.1:10080/apioak/admin/router/{id}/plugin?service_id={service_id}&plugin_name=limit-conn
```

### 接口上下线
```shell
curl -X GET http://127.0.0.1:10080/apioak/admin/router/{id}/push_upstream -d '
{
    "service_id": "00000000000000010080",
    "push_upstream": "beta",
    "push_status": true
}'
```